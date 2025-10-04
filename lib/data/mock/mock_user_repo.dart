class User {
  final String name;
  final String phone;

  User({
    required this.name,
    required this.phone,
  });
}

// Mock repository (swap with API or DB later)
class MockUserRepo {
  static User getUser() {
    return User(
      name: "Heng HuyLong",
      phone: "+855 6*****18",
    );
  }
}
