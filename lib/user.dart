class User {
  String name = "";
  String phone = "";
  String code = "";

  User({required this.name, required this.phone,  required this.code});

  String get getName => name;
  set setName(String name) => this.name = name;
  String get getId => code;
  set setId(String code) => this.code = code;
  String get getNumber => phone;
  set setPhone(String phone) => this.phone = phone;

  void setInit() {
    name = "";
    phone = "";
    code = "";
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'code': code,
  };
}

