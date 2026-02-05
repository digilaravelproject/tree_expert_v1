class PayslipModel {
  final int id;
  final String userName;
  final String paymentId;
  final String amount;
  final String treeNo;
  final String treeName;
  final String latitude;
  final String longitude;
  final String address;
  final String date;

  PayslipModel({
    required this.id,
    required this.userName,
    required this.paymentId,
    required this.amount,
    required this.treeNo,
    required this.treeName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.date,
  });

  factory PayslipModel.fromJson(Map<String, dynamic> json) {
    return PayslipModel(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      paymentId: json['payment_id'] ?? '',
      amount: json['amount'] ?? '0.00',
      treeNo: json['tree_no'] ?? '',
      treeName: json['tree_name'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      address: json['address'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class PayslipResponse {
  final bool success;
  final String message;
  final int count;
  final List<PayslipModel> data;

  PayslipResponse({
    required this.success,
    required this.message,
    required this.count,
    required this.data,
  });

  factory PayslipResponse.fromJson(Map<String, dynamic> json) {
    return PayslipResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data: (json['data'] as List? ?? [])
          .map((e) => PayslipModel.fromJson(e))
          .toList(),
    );
  }
}