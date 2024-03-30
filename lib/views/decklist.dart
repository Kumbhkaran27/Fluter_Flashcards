import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mp3/models/cards.dart';
import 'package:mp3/views/editDeckScreen.dart';
import 'cardlist.dart';
import '../utils/dbHelper.dart';

class DeckList extends StatefulWidget {
  const DeckList({super.key});

  @override
  _DecklistState createState() => _DecklistState();
}

class _DecklistState extends State<DeckList> {
  _DecklistState();
  List<List<Map<String, dynamic>>> cardLists = [];
  List<Map<String, String>> flashcards = [];
  DatabaseHelper dbHelper = DatabaseHelper();
  List<DeckData> deckLists = [];

  @override
  void initState() {
    super.initState();
    loadDeckData();
  }

  void addItem() {
    final newDeck = DeckData(
        id: 0, title: 'New Deck', flashcards: []); // new ID is generated
    dbHelper.insertDeck(newDeck).then((deckId) {
      if (deckId != null) {
        // Update the DeckData instance with the correct id
        final updatedDeck = newDeck.copyWith(id: deckId);
        // Reload data after adding a new deck
        loadDeckData(updatedDeck);
      }
    });
  }

  void loadDeckData([DeckData? newDeck]) async {
    final decks = await dbHelper.fetchDecks();
    if (mounted) {
      setState(() {
        deckLists = decks ?? [];
      });
    }
  }

  void onCardsUpdated() {
    loadDeckData();
  }

  void deleteItem(int index) {
    dbHelper.deleteDeck(deckLists[index]).then((_) {
      loadDeckData();
    });
  }

  void editItem(int index, String newItem) {
    final updatedDeck = deckLists[index].copyWith(
        title: newItem); // Assuming you have a copyWith method on DeckData
    dbHelper.updateDeck(updatedDeck).then((_) {
      loadDeckData(); // Reload data after editing a deck
    });
  }

  Future<void> populateDatabase() async {
    final String jsonString =
        await rootBundle.loadString('assets/flashcards.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    int deckIdCounter = 1; // Initialize a counter for deckId generation
    int cardIdCounter = 1; // Initialize a counter for cardId generation

    for (var deckData in jsonData) {
      final DeckData deck = DeckData(
        id: deckIdCounter, // Use the counter value as the deckId
        title: deckData['title'],
        flashcards: (deckData['flashcards'] as List)
            .map((cardData) => CardData(
                  id: cardIdCounter++, // Use the counter value as the cardId
                  deckId:
                      deckIdCounter, // Use the current deckIdCounter value as the deckId
                  question: cardData['question'],
                  answer: cardData['answer'],
                ))
            .toList(),
      );
      await dbHelper.insertDeck(deck);

      deckIdCounter++; // Increment the deckIdCounter for the next iteration
    }
  }

  Future<void> handlePopulateDatabase() async {
    final decks = await dbHelper.fetchDecks();
    if (decks == null || decks.isEmpty) {
      await populateDatabase();
      loadDeckData();
    }
  }

  @override
  Widget build(BuildContext context) {
    int columnsCount =
        MediaQuery.of(context).size.width ~/ 150; // Adjust 150 as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text(' Flashcards Game '),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: handlePopulateDatabase,
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsCount,
        ),
        padding: const EdgeInsets.all(4),
        itemCount: deckLists.length,
        itemBuilder: (context, index) {
          final deck = deckLists[index];
          // Create a CardList instance for each grid item
          return Card(
            color: Color.fromARGB(255, 217, 46, 46),
            child: Container(
              alignment: Alignment.center,
              child: Stack(
                children: [
                  InkWell(
                    onTap: () {
                      // Navigate to the second page when a grid item is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CardList(
                              deckId: deck.id,
                              flashcards: deck.flashcards,
                              onCardsUpdated: onCardsUpdated),
                        ),
                      );
                    },
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Text(
                              deckLists[index].title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              textScaleFactor: 1.3,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Center(
                              child: Text(
                            "Cards: ${deckLists[index].flashcards.length}",
                          ))
                        ]),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () async {
                            final newDeckName = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDeckScreen(
                                  deckIndex: index,
                                  initialDeckName: deckLists[index].title,
                                ),
                              ),
                            );
                            if (newDeckName != null) {
                              editItem(index, newDeckName);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            deleteItem(index);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}
