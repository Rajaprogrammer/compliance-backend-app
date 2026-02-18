class ClientModel {
  final String id;
  final String name;
  final String? pan;
  final String? gstin;
  final String? primaryEmail;

  ClientModel({
    required this.id,
    required this.name,
    this.pan,
    this.gstin,
    this.primaryEmail,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json, String id) {
    return ClientModel(
      id: id,
      name: json['name'] ?? '',
      pan: json['pan'],
      gstin: json['gstin'],
      primaryEmail: json['primaryEmail'],
    );
  }
}
