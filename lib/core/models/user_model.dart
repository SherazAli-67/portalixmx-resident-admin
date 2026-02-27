class UserModel {
  final String userID;
  final String userName;
  final String email;
  final String? phoneNum;
  final DateTime createdAt;
  final String? profileImg;
  final VehicleInformation? vehicleInformation;
  final String societyID;
  final List<String> emergencyContacts;

  UserModel({
    required this.userID,
    required this.userName,
    required this.email,
    required this.createdAt,
    this.profileImg,
    this.phoneNum,
    required this.societyID,
    this.vehicleInformation,
    this.emergencyContacts = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'emailAddress': email,
      'phoneNum' : phoneNum,
      'societyID': societyID,
      'createdAt': createdAt.toIso8601String(),
      'profileImg': profileImg,
      'vehicleInformation': vehicleInformation?.toMap(),
      'emergencyContacts': emergencyContacts,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userID: map['userID'] ?? '',
      userName: map['userName'] ?? '',
      email: map['emailAddress'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      profileImg: map['profileImg'],
      phoneNum: map['phoneNum'],
      societyID: map['societyID'],
      vehicleInformation: map['vehicleInformation'] != null
          ? VehicleInformation.fromMap(
          Map<String, dynamic>.from(map['vehicleInformation']))
          : null,
      emergencyContacts: map['emergencyContacts'] != null
          ? List<String>.from(map['emergencyContacts'])
          : [],
    );
  }

  UserModel copyWith({
    String? userID,
    String? userName,
    String? email,
    DateTime? createdAt,
    String? profileImg,
    String? phoneNum,
    String? societyID,
    VehicleInformation? vehicleInformation,
    List<String>? emergencyContacts,
  }) {
    return UserModel(
      userID: userID ?? this.userID,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      profileImg: profileImg ?? this.profileImg,
      phoneNum: phoneNum ?? this.phoneNum,
      societyID: societyID ?? this.societyID,
      vehicleInformation:
      vehicleInformation ?? this.vehicleInformation,
      emergencyContacts:
      emergencyContacts ?? this.emergencyContacts,
    );
  }
}


class VehicleInformation {
  final String name;
  final String color;
  final String licensePlateNumber;
  final String registrationNumber;

  VehicleInformation({
    required this.name,
    required this.color,
    required this.registrationNumber,
    required this.licensePlateNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'licensePlateNumber': licensePlateNumber,
      'registrationNumber': registrationNumber,
    };
  }

  factory VehicleInformation.fromMap(Map<String, dynamic> map) {
    return VehicleInformation(
      name: map['name'] ?? '',
      color: map['color'] ?? '',
      licensePlateNumber: map['licensePlateNumber'] ?? '',
      registrationNumber: map['registrationNumber'] ?? '',
    );
  }

  VehicleInformation copyWith({
    String? name,
    String? color,
    String? licensePlateNumber,
    String? registrationNumber,
  }) {
    return VehicleInformation(
      name: name ?? this.name,
      color: color ?? this.color,
      licensePlateNumber:
      licensePlateNumber ?? this.licensePlateNumber,
      registrationNumber:
      registrationNumber ?? this.registrationNumber,
    );
  }
}