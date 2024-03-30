import 'package:flutter/material.dart';
import '../models/cards.dart'; // Import the CardData model

class CardScreen extends StatefulWidget {
  final List<CardData> flashcards;

  const CardScreen({super.key, required this.flashcards});

  @override
  _CardScreenState createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  int currentIndex = 0;
  bool isFlipped = false;
  int seenCount = 1;
  int peekedCount = 0;
  Set<int> seenIndices = {};
  Set<int> peekedIndices = {};

  void nextCard() {
    setState(() {
      currentIndex = (currentIndex + 1) % widget.flashcards.length;
      isFlipped = false;
      if (!seenIndices.contains(currentIndex)) {
        seenCount++;
        seenIndices.add(currentIndex);
      }
    });
  }

  void prevCard() {
    setState(() {
      currentIndex = (currentIndex - 1 + widget.flashcards.length) %
          widget.flashcards.length;
      isFlipped = false;
      if (!seenIndices.contains(currentIndex)) {
        seenCount++;
        seenIndices.add(currentIndex);
      }
    });
  }

  void flipCard() {
    setState(() {
      isFlipped = !isFlipped;
      if (isFlipped && !peekedIndices.contains(currentIndex)) {
        peekedCount++;
        peekedIndices.add(currentIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final flashcard = widget.flashcards[currentIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: flipCard,
            child: Card(
              color:
                  isFlipped ? Colors.green[300] : Colors.deepOrangeAccent[200],
              child: SizedBox(
                width: screenSize.width * 0.8,
                height: screenSize.height * 0.6,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          isFlipped ? 'Answer' : 'Question',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 25),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        isFlipped ? flashcard.answer : flashcard.question,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 45),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: prevCard,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded),
                onPressed: nextCard,
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text('Seen: $seenCount / ${widget.flashcards.length}'),
              IconButton(
                icon: const Icon(Icons.ads_click_outlined),
                onPressed: flipCard,
              ),
              Text('Peeked: $peekedCount / $seenCount'),
            ],
          ),
        ),
      ),
    );
  }
}
