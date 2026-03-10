class TradeCompletionModel {
  final int tradeId;
  final int amount;
  final bool isTradeComplete;

  TradeCompletionModel({
    required this.tradeId,
    required this.amount,
    required this.isTradeComplete,
  });

  factory TradeCompletionModel.fromJson(Map<String, dynamic> json) {
    return TradeCompletionModel(
      tradeId: json['trade_id'] ?? 0,
      amount: json['amount'] ?? 0,
      isTradeComplete: json['is_trade_complete'] ?? false,
    );
  }
}
