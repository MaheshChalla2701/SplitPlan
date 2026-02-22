import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  return OcrService();
});

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<double?> extractTotalAmount(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(
      inputImage,
    );

    final String fullText = recognizedText.text;

    // 1. Pass 1: Look for explicit keywords on the exact same line text.
    final RegExp explicitRegex = RegExp(
      r'(?:mrp|total\s*due|total\s*amount|bill\s*amount|grand\s*total|amount\s*payable|net\s*pay|net\s*amount|subtotal|balance\s*due|total|amount|pay|rs\.?|rupees|₹|\$)\s*[:\-]?\s*(?:rs\.?|rupees|₹|\$)?\s*(\d+(?:[.,]\d{1,2})?)',
      caseSensitive: false,
      multiLine: true,
    );

    final explicitMatches = explicitRegex.allMatches(fullText);
    double? bestAmount;

    for (final match in explicitMatches) {
      String? matchedStr = match.group(1);
      if (matchedStr != null) {
        matchedStr = matchedStr.replaceAll(',', '.');
        final double? parsed = double.tryParse(matchedStr);
        // Cap to 1 million to avoid weird edge parses
        if (parsed != null && parsed < 1000000) {
          if (bestAmount == null || parsed > bestAmount) {
            bestAmount = parsed;
          }
        }
      }
    }

    if (bestAmount != null && bestAmount > 0) {
      return bestAmount;
    }

    // 2. Pass 2: Spatial Check (Utility bills with detached columns)
    // We collect all blocks and lines, find the label, and look horizontally across the page.
    final List<TextLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    final RegExp keywordRegex = RegExp(
      r'(?:mrp|total\s*due|total\s*amount|bill\s*amount|grand\s*total|amount\s*payable|net\s*pay|net\s*amount|subtotal|balance\s*due|total|amount|pay)',
      caseSensitive: false,
    );
    final RegExp amountRegex = RegExp(r'\b\d+(?:[.,]\d{1,2})?\b');

    for (final line in allLines) {
      if (keywordRegex.hasMatch(line.text)) {
        // Calculate the vertical center of the keyword line
        final double centerY =
            line.boundingBox.top + (line.boundingBox.height / 2);

        for (final otherLine in allLines) {
          if (line == otherLine) continue;

          final double otherCenterY =
              otherLine.boundingBox.top + (otherLine.boundingBox.height / 2);

          // If the other line is horizontally aligned with the keyword line (within half a line height gap)
          if ((centerY - otherCenterY).abs() < line.boundingBox.height) {
            final matches = amountRegex.allMatches(otherLine.text);
            for (final match in matches) {
              String? matchedStr = match.group(0);
              if (matchedStr != null) {
                matchedStr = matchedStr.replaceAll(',', '.');
                final double? parsed = double.tryParse(matchedStr);
                // Assume utility bills don't exceed 1,000,000
                if (parsed != null && parsed < 1000000) {
                  if (bestAmount == null || parsed > bestAmount) {
                    bestAmount = parsed;
                  }
                }
              }
            }
          }
        }
      }
    }

    if (bestAmount != null && bestAmount > 0) {
      return bestAmount;
    }

    // 3. Pass 3: Strict Decimal Currency Fallback
    // To strictly avoid MRIDs, Consumer Numbers, Zips, etc, look only for numbers that end in .00 or .XX
    final RegExp strictCurrencyRegex = RegExp(r'\b\d+[.,]\d{2}\b');
    final strictMatches = strictCurrencyRegex.allMatches(fullText);
    for (final match in strictMatches) {
      String matchedStr = match.group(0)!.replaceAll(',', '.');
      final parsed = double.tryParse(matchedStr);
      // Prices with decimals usually don't exceed 100,000 for everyday app splitting
      if (parsed != null && parsed <= 100000) {
        if (bestAmount == null || parsed > bestAmount) bestAmount = parsed;
      }
    }

    if (bestAmount != null && bestAmount > 0) {
      return bestAmount;
    }

    // 4. Maximum value fallback under a reasonable hard cap (50,000)
    final matchesFallback = amountRegex.allMatches(fullText);
    for (final match in matchesFallback) {
      String matchedStr = match.group(0)!.replaceAll(',', '.');
      final parsed = double.tryParse(matchedStr);
      if (parsed != null && parsed <= 50000) {
        if (bestAmount == null || parsed > bestAmount) bestAmount = parsed;
      }
    }

    return (bestAmount != null && bestAmount > 0.0) ? bestAmount : null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
