import '../entities/settlement_entity.dart';

abstract class SettlementRepository {
  Future<SettlementEntity> recordSettlement(SettlementEntity settlement);
  Future<List<SettlementEntity>> getGroupSettlements(String groupId);
  Stream<List<SettlementEntity>> watchGroupSettlements(String groupId);
}
