class Member {
  final String id;      // Unique ID (UUID or index)
  final String name;

  Member({
    required this.id,
    required this.name,
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] as String,
      name: data['name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
