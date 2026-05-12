enum ToneMode {
  balancedReferee(
    'balanced_referee',
    'Balanced Referee',
    'Fair, calm, useful, lightly funny.',
  ),
  playfulRoast(
    'playful_roast',
    'Playful Roast',
    "Teasing the situation, not destroying anyone's soul.",
  ),
  courtroomJudge(
    'courtroom_judge',
    'Courtroom Judge',
    'Mock trial energy. Tiny gavel included.',
  );

  const ToneMode(this.wireValue, this.label, this.description);

  final String wireValue;
  final String label;
  final String description;

  static const ToneMode defaultTone = ToneMode.balancedReferee;
}
