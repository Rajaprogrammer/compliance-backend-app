class ClientModel {
  final String id;
  final String name;
  final String? pan;
  final String? gstin;
  final String? cin;
  final String? assessmentYear;
  final String? engagementType;
  final String? primaryEmail;
  final List<String> ccEmails;
  final List<String> bccEmails;

  ClientModel({
    required this.id,
    required this.name,
    this.pan,
    this.gstin,
    this.cin,
    this.assessmentYear,
    this.engagementType,
    this.primaryEmail,
    this.ccEmails = const [],
    this.bccEmails = const [],
  });

  factory ClientModel.fromJson(Map<String, dynamic> json, String id) {
    return ClientModel(
      id: id,
      name: json['name'] ?? '',
      pan: json['pan'],
      gstin: json['gstin'],
      cin: json['cin'],
      assessmentYear: json['assessmentYear'],
      engagementType: json['engagementType'],
      primaryEmail: json['primaryEmail'],
      ccEmails: json['ccEmails'] != null ? List<String>.from(json['ccEmails']) : [],
      bccEmails: json['bccEmails'] != null ? List<String>.from(json['bccEmails']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'pan': pan,
    'gstin': gstin,
    'cin': cin,
    'assessmentYear': assessmentYear,
    'engagementType': engagementType,
    'primaryEmail': primaryEmail,
    'ccEmails': ccEmails,
    'bccEmails': bccEmails,
  };
}
