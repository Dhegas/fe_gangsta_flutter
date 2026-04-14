class FeeDeductionEntity {
  const FeeDeductionEntity({required this.label, required this.amount});

  final String label;
  final double amount;
}

class PayoutEntity {
  const PayoutEntity({
    required this.dateLabel,
    required this.amount,
    required this.status,
  });

  final String dateLabel;
  final double amount;
  final String status;
}

class ReportFinancialEntity {
  const ReportFinancialEntity({
    required this.fees,
    required this.payouts,
    required this.refundAmount,
    required this.refundCount,
  });

  final List<FeeDeductionEntity> fees;
  final List<PayoutEntity> payouts;
  final double refundAmount;
  final int refundCount;
}
