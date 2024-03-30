import 'package:mp3/models/cards.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();

    var dbpath = path.join(dbDir.path, 'flashcards_database.db');

    //String path = join(await getDatabasesPath(), 'flashcards_database.db');
    var db = await openDatabase(
      dbpath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
            CREATE TABLE decks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deck_id INTEGER,
            question TEXT,
            answer TEXT,
            FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return db;
  }

  Future<bool> areTablesCreated() async {
    final db = await database;
    final result = await db?.rawQuery('''
      SELECT name FROM sqlite_master WHERE type='table' AND (name='decks' OR name='cards')
    ''');
    return result?.length == 2; // Both 'decks' and 'cards' tables exist
  }

  Future<int?> insertDeck(DeckData deck) async {
    final db = await database;
    // Only one insert statement to add a new deck to the database
    await db?.insert('decks', {'title': deck.title},
        conflictAlgorithm: ConflictAlgorithm.replace);
    // Get the id of the newly inserted deck
    final int? deckId =
        Sqflite.firstIntValue(await db!.rawQuery('SELECT last_insert_rowid()'));
    if (deckId != null) {
      // Ensure deckId is non-null
      for (var card in deck.flashcards) {
        card = card.copyWith(deckId: deckId);
        await insertCard(card);
      }
    }
    return deckId;
  }

  Future<void> insertCard(CardData card) async {
    final db = await database;
    await db?.insert('cards', card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDeck(DeckData deck) async {
    final db = await database;
    await db?.update('decks', {'title': deck.title},
        where: 'id = ?', whereArgs: [deck.id]);
  }

  Future<void> editCard(CardData card) async {
    final db = await database;
    await db?.update(
      'cards',
      card.toMap(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteDeck(DeckData deck) async {
    final db = await database;
    final int deckId = deck.id;
    await db?.delete('decks', where: 'id = ?', whereArgs: [deckId]);
    await db?.delete('cards', where: 'deck_id = ?', whereArgs: [deckId]);
  }

  Future<void> deleteCard(int cardId) async {
    final db = await database;
    await db?.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }

  Future<List<DeckData>?> fetchDecks() async {
    final db = await database;
    final tablesCreated = await areTablesCreated();
    if (!tablesCreated) {
      print('Tables are not created yet.');
      return null;
    }

    final List<Map<String, dynamic>>? deckMaps = await db?.query('decks');
    if (deckMaps == null || deckMaps.isEmpty) {
      return null; // Return null or handle accordingly
    }
    List<DeckData> decks = [];
    for (var deckMap in deckMaps) {
      final deckId = deckMap['id'];
      final flashcardMaps =
          await db?.query('cards', where: 'deck_id = ?', whereArgs: [deckId]);
      if (flashcardMaps == null) {
        return null; // Return null or handle accordingly
      }
      final flashcards =
          flashcardMaps.map((cardMap) => CardData.fromMap(cardMap)).toList();
      decks.add(DeckData.fromMap({...deckMap, 'flashcards': flashcards}));
    }
    return decks;
  }

  Future<List<Map<String, dynamic>>?> fetchCards(int deckId) async {
    final db = await database;
    return await db?.query('cards', where: 'deck_id = ?', whereArgs: [deckId]);
  }
}
