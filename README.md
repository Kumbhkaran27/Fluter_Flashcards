📘 Flutter Flashcards

A cross-platform Flutter mobile app to create, edit, manage decks of flashcards and run quizzes — with local persistence using SQLite and a responsive UI.

🚀 Features

✅ Create, edit, and delete decks
✅ Create, edit, sort, and delete flashcards
✅ Run shuffle quizzes with progress tracking
✅ Load starter decks from a JSON file
✅ Offline persistence with sqflite
✅ Responsive UI for different screen sizes

📱 Demo

🔥 Clickable, interactive UI
🎯 Real-time quiz play
📂 Deck and card management

🧠 Why this App?

This app was built as part of a course project (CS 442 MP3).
It demonstrates key Flutter concepts: navigation, responsive UI, state management, persistence, and modular architecture.

📦 Tech Stack
Layer	Technology
UI	Flutter (Material)
State	Provider
Persistence	SQLite via sqflite
File System	path_provider, path
Asset Data	JSON starter file
Languages	Dart

🗂 Project Structure
lib/
├── models/        # Flashcard and Deck models
├── views/         # Screens (DeckList, CardList, Quiz, Editors)
├── utils/         # DB helper, JSON loader, helpers
├── main.dart
assets/
└── flashcards.json

💡 How It Works

Deck List
Shows all decks with card counts.
Buttons: Create deck + Load starter JSON.

Card List
Shows cards in selected deck.
Options: Edit, delete, sort.

Card Editor
Add or update question & answer.

Quiz Screen
Shuffles cards on start, shows progress, lets user flip & navigate.

Persistence
Data stored locally using SQLite; survives app restart.

🧰 Setup
Prerequisites

Flutter SDK

Dart SDK

IDE (VS Code, Android Studio)

Android/iOS device or emulator

🛠 Installation
# Clone your repo
git clone https://github.com/Kumbhkaran27/Fluter_Flashcards.git
cd Fluter_Flashcards

# Install dependencies
flutter pub get

# Run on connected device / emulator
flutter run

🧾 JSON Starter Data

To preload decks and cards:

Open the app

Tap Load Starter Decks

The app reads assets/flashcards.json and inserts into DB

Uses Flutter’s rootBundle + jsonDecode

Stored into SQLite ➝ decks + cards tables

🧠 Database

Uses sqflite package for SQLite

Two tables:

decks — stores deck metadata

cards — stores flashcards, linked with a deck foreign key

All DB access is async and non-blocking.

📍 Navigation

Navigation is managed using Flutter’s Navigator:

Navigator.push(...)
Navigator.pop(...)


This enables clean transitions between screens.

📐 UI Responsiveness

The app adapts to screen size:

Small screens: separate list pages

Large screens: optional split view

Cards layout grid or list based on width

🧪 Testing Checklist

Create deck ➜ works

Edit deck ➜ saved

Create card ➜ shows up

Quiz runs without crash

Decks load from JSON

All screens navigate smoothly
