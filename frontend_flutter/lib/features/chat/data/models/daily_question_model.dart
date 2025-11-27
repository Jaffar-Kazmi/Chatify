import '../../domain/entities/daily_question_entity.dart';

class DailyQuestionModel extends DailyQuestionEntity{

  DailyQuestionModel({required String question}): super(
    question: question
  );

  factory DailyQuestionModel.fromJson(Map<String, dynamic> json) {
    return DailyQuestionModel(
      question: json['question'] ?? 'No question available',
    );
  }

}

