class Finance {
  final String id;
  final double amount;
  final String type; // income, expense
  final String category; // 餐饮, 交通, 购物, 娱乐, 住房, 医疗, 教育, 工资, 投资, 其他
  final String? description;
  final DateTime date;
  final String? paymentMethod; // 现金, 支付宝, 微信, 银行卡, 信用卡, 其他
  final DateTime createdAt;
  final DateTime updatedAt;

  Finance({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.description,
    required this.date,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });
} 