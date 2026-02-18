class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role;
  final bool active;
  final String? managerEmail;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.active = true,
    this.managerEmail,
  });

  bool get isPartner => role.toUpperCase() == 'PARTNER';
  bool get isManager => role.toUpperCase() == 'MANAGER';
  bool get isAssociate => role.toUpperCase() == 'ASSOCIATE';
  bool get canSeeAllTasks => isPartner || isManager;
  bool get canEditDetails => isPartner || isManager;
  bool get canAccessClients => isPartner;
  bool get canAccessOps => isPartner || isManager;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String normalizedRole = (json['role'] ?? 'ASSOCIATE').toString().toUpperCase().trim();
    if (normalizedRole.isEmpty || normalizedRole == 'WORKER') {
      normalizedRole = 'ASSOCIATE';
    }
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: normalizedRole,
      active: json['active'] ?? true,
      managerEmail: json['managerEmail'],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'role': role,
    'active': active,
    'managerEmail': managerEmail,
  };
}
