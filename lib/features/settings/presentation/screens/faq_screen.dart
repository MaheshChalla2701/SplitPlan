import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FAQs')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          _FaqItem(
            question: '1. What is SplitPlan?',
            answer:
                'SplitPlan is a simple and efficient app for managing group expenses and settling debts with friends.',
          ),
          _FaqItem(
            question: '2. How do I add a friend?',
            answer:
                'Navigate to the \'Friends\' tab and use the search or invite feature to add friends to your network.',
          ),
          _FaqItem(
            question: '3. Can I track personal expenses?',
            answer:
                'Currently, SplitPlan focuses on shared group expenses, but you can create a solo group to track personal spending.',
          ),
          _FaqItem(
            question: '4. How are balances calculated?',
            answer:
                'Our algorithm automatically simplifies debts within a group to minimize the number of transactions needed to settle up.',
          ),
          _FaqItem(
            question: '5. Is SplitPlan free?',
            answer:
                'Yes, the core features of SplitPlan are completely free to use!',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          const SizedBox(height: 8.0),
          Text(answer, style: const TextStyle(fontSize: 14.0)),
        ],
      ),
    );
  }
}
