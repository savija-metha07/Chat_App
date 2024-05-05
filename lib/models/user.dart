class User {
  final String id;
  final String name;
  final String mobileNumber;
  final String profile;
  final String about;
  final String satus;

  User({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.profile,
    required this.about,
    required this.satus,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      name: map['name'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      profile: map['profile'] ?? '',
      about: map['about'] ?? '',
      satus: map['satus'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobileNumber': mobileNumber,
      'profile': profile,
      'about': about,
      'satus':satus
    };
  }
}
