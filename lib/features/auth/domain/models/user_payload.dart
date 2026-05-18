class UserPayload {
  final String name;
  final String age;
  final List<String> favoriteGenres;
  final String email;
  final String password;

  UserPayload({
    required this.name,
    required this.age,
    required this.favoriteGenres,
    required this.email,
    required this.password,
  });
}
