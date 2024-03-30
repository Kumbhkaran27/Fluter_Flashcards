import 'package:flutter/material.dart';

class EditDeckScreen extends StatelessWidget {
  final int deckIndex;
  final String initialDeckName;
  final TextEditingController _deckNameController;

  EditDeckScreen({super.key, 
    required this.deckIndex,
    required this.initialDeckName,
  }) : _deckNameController = TextEditingController(text: initialDeckName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Deck'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _deckNameController,
              decoration: const InputDecoration(labelText: 'Deck Name'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _deckNameController.text);
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
