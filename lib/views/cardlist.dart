import 'package:flutter/material.dart';
import 'package:mp3/views/cardSeen.dart';
import 'editCardScreen.dart';
import '../utils/dbHelper.dart';
import '../models/cards.dart';

class CardList extends StatefulWidget {
  final List<CardData> flashcards;
  final int deckId;
  final VoidCallback onCardsUpdated;

  const CardList(
      {Key? key,
      required this.deckId,
      required this.flashcards,
      required this.onCardsUpdated})
      : super(key: key);

  @override
  _CardListState createState() => _CardListState();
}

class _CardListState extends State<CardList> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<CardData> originalOrder = [];
  List<CardData> sortedOrder = [];
  bool isSorted = false;

  _CardListState();

  @override
  void initState() {
    super.initState();
    originalOrder = List.from(widget.flashcards);
  }

  void editItem(int index, CardData updatedFlashcard) {
  dbHelper.editCard(updatedFlashcard).then((_) {
    setState(() {
      // Update the card at the correct index in originalOrder
      originalOrder[index] = updatedFlashcard;

      // If sorted, update the sortedOrder list as well
      if (isSorted) {
        sortedOrder = List.from(originalOrder)
          ..sort((a, b) => a.question.compareTo(b.question));
      }
    });
    widget.onCardsUpdated(); // Update the parent widget
  });
}

  void addCard(CardData newCard) {
    dbHelper.insertCard(newCard).then((_) {
      setState(() {
        originalOrder
            .add(newCard); // Update the originalOrder list with the new card

        // If the list is sorted, update the sortedOrder list as well
        sortedOrder = List.from(originalOrder)
          ..sort((a, b) => a.question.compareTo(b.question));
      });
      widget.onCardsUpdated(); // Update the parent widget
    });
  }

  void deleteCard(int index) {
    int idToDelete = isSorted ? sortedOrder[index].id : originalOrder[index].id;
    widget.flashcards.removeAt(index);
    dbHelper.deleteCard(idToDelete).then((_) {
      setState(() {
        originalOrder.removeWhere((card) => card.id == idToDelete);
        sortedOrder.removeWhere((card) => card.id == idToDelete);

        sortedOrder = List.from(originalOrder)
          ..sort((a, b) => a.question.compareTo(b.question));
      });
    });
    reloadCardData();
    widget.onCardsUpdated();
  }

  void sortFlashcards() {
    setState(() {
      if (isSorted) {
        isSorted = false;
      } else {
        if (sortedOrder.isEmpty) {
          sortedOrder = List.from(originalOrder)
            ..sort((a, b) => a.question.compareTo(b.question));
        }
        isSorted = true;
      }
    });
  }

  void reloadCardData() async {
    final dbCards = await dbHelper.fetchCards(widget.deckId);
    if (dbCards != null) {
      setState(() {
        originalOrder =
            dbCards.map((cardMap) => CardData.fromMap(cardMap)).toList();

        sortedOrder = List.from(originalOrder)
          ..sort((a, b) => a.question.compareTo(b.question));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int columnsCount = MediaQuery.of(context).size.width ~/ 150;
    List<CardData> currentView = isSorted ? sortedOrder : originalOrder;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashCards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_by_alpha),
            onPressed: sortFlashcards,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CardScreen(flashcards: widget.flashcards),
                ),
              );
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsCount,
        ),
        itemCount: currentView.length,
        padding: const EdgeInsets.all(3),
        itemBuilder: (context, index) {
          final flashcard = currentView[index];
          final question = flashcard.question;

          return Card(
            color: const Color.fromARGB(255, 221, 249, 144),
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCardScreen(
                            flashcard: flashcard,
                            onSave: (updatedFlashcard) =>
                                editItem(index, updatedFlashcard),
                          ),
                        ),
                      );
                    },
                  ),
                  Center(
                      child: Text(question,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19))),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => deleteCard(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCardScreen(
                                flashcard: flashcard,
                                onSave: (updatedFlashcard) =>
                                    editItem(index, updatedFlashcard),
                              ),
                            ),
                          );
                        },
                      )
                    ]),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final newCard = CardData(
            id: 0,
            deckId: widget.deckId,
            question: 'New Question',
            answer: 'New Answer',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditCardScreen(
                flashcard: newCard,
                onSave: (updatedFlashcard) => addCard(updatedFlashcard),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
