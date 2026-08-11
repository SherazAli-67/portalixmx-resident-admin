class PollOption {
  final String id;
  final String text;
  final int voteCount;

  PollOption({required this.id, required this.text, this.voteCount = 0});

  Map<String, dynamic> toMap() {
    return {'id': id, 'text': text, 'voteCount': voteCount};
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      voteCount: map['voteCount'] as int? ?? 0,
    );
  }

  PollOption copyWith({String? id, String? text, int? voteCount}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}

class CommunityPollModel {
  final String id;
  final String question;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? endsAt;
  final String? imageUrl;
  final String societyID;
  final List<PollOption> options;

  CommunityPollModel({
    required this.id,
    required this.question,
    required this.createdBy,
    required this.createdAt,
    this.endsAt,
    this.imageUrl,
    required this.societyID,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'createdBy': createdBy,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'endsAt': endsAt?.millisecondsSinceEpoch,
      'imageUrl': imageUrl,
      'societyID': societyID,
      'options': options.map((e) => e.toMap()).toList(),
    };
  }

  factory CommunityPollModel.fromMap(Map<String, dynamic> map) {
    final optionsList = map['options'];
    return CommunityPollModel(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      createdBy: map['createdBy'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int? ?? 0),
      endsAt: map['endsAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endsAt'] as int) : null,
      imageUrl: map['imageUrl'] as String?,
      societyID: map['societyID'] ?? '',
      options: optionsList is List
          ? (optionsList).map((e) => PollOption.fromMap(e as Map<String, dynamic>)).toList()
          : [],
    );
  }

  CommunityPollModel copyWith({
    String? id,
    String? question,
    String? createdBy,
    DateTime? createdAt,
    DateTime? endsAt,
    String? imageUrl,
    String? societyID,
    List<PollOption>? options,
  }) {
    return CommunityPollModel(
      id: id ?? this.id,
      question: question ?? this.question,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      endsAt: endsAt ?? this.endsAt,
      imageUrl: imageUrl ?? this.imageUrl,
      societyID: societyID ?? this.societyID,
      options: options ?? this.options,
    );
  }
}
