import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.type,
    required super.amount,
    super.referenceType,
    super.referenceId,
    super.note,
    super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type'] as String? ?? 'UNKNOWN',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id']?.toString(),
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}
