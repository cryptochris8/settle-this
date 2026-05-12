enum RelationshipType {
  partner('partner', 'Partner'),
  roommate('roommate', 'Roommate'),
  friend('friend', 'Friend'),
  family('family', 'Family'),
  coworker('coworker', 'Coworker'),
  other('other', 'Other');

  const RelationshipType(this.wireValue, this.label);

  /// Value sent to the backend / stored in Firestore.
  final String wireValue;

  /// Human-friendly label shown in the UI.
  final String label;
}
