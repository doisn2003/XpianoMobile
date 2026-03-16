class Transaction {
  final int id;
  final String type;
  final double amount;
  final String? referenceType;
  final String? referenceId;
  final String? note;
  final String? createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    this.referenceType,
    this.referenceId,
    this.note,
    this.createdAt,
  });
}
