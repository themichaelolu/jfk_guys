class Participant {
  final String id;
  final String name;

  Participant({required this.id, required this.name});

  // From a map (like the data from Firestore) to a Participant object
  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(id: map['id'] ?? '', name: map['name'] ?? '');
  }

  // From a Participant object to a map for storing in Firestore
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
