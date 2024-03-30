// Define a class to represent the structure of the JSON data.
/*class DeckData {
  final String title;
  final List<Map<String, String>> flashcards;

  DeckData(this.title, this.flashcards);
}
*/

// cards.dart
class DeckData {
  final int id;
  final String title;
  final List<CardData> flashcards;

  DeckData({required this.id, required this.title, required this.flashcards});

  factory DeckData.fromMap(map) {
    var list = map['flashcards'] as List;
    List<CardData> flashcardList = list.cast<CardData>();

    return DeckData(
      id: map['id'],
      title: map['title'],
      flashcards: flashcardList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'flashcards': flashcards.map((card) => card.toMap()).toList(),
    };
  }

  DeckData copyWith({int? id, String? title, List<CardData>? flashcards}) {
    return DeckData(
      id: id ?? this.id,
      title: title ?? this.title,
      flashcards: flashcards ?? this.flashcards,
    );
  }

  factory DeckData.fromJson(Map<String, dynamic> json, id) {
    return DeckData(
      id: id,
      title: json['title'],
      flashcards: (json['flashcards'] as List)
          .map((flashcardJson) => CardData.fromJson(flashcardJson, id))
          .toList(),
    );
  }
}

class CardData {
  final int id;
  final int deckId;
  final String question;
  final String answer;

  CardData(
      {required this.id,
      required this.deckId,
      required this.question,
      required this.answer});

  factory CardData.fromMap(Map<String, dynamic> map) {
    return CardData(
      id: map['id'],
      deckId: map['deck_id'],
      question: map['question'],
      answer: map['answer'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deck_id': deckId,
      'question': question,
      'answer': answer,
    };
  }

  CardData copyWith({int? deckId}) {
    return CardData(
      deckId: deckId ?? this.deckId,
      id: id,
      question: question,
      answer: answer,
    );
  }

  factory CardData.fromJson(Map<String, dynamic> json, id) {
    return CardData(
      id: id,
      deckId: json['deck_id'],
      question: json['question'],
      answer: json['answer'],
    );
  }
}
