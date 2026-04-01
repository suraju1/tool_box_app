class FaqModel {
  final int id;
  final int sequenceNo;
  final String question;
  final String answer;
  final int status;
  final DateTime createdAt;

  FaqModel({
    required this.id,
    required this.sequenceNo,
    required this.question,
    required this.answer,
    required this.status,
    required this.createdAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['id'] ?? 0,
      sequenceNo: json['sequence_no'] ?? 0,
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      status: json['status'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequence_no': sequenceNo,
      'question': question,
      'answer': answer,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
