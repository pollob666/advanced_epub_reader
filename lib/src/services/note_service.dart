import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Service for managing notes in EPUB books
class NoteService {
  static const String _storageKey = 'epub_notes';

  /// Saves a note to local storage
  static Future<void> saveNote(Note note) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getNotes(note.bookId);

      // Add new note
      notes.add(note);

      // Save to storage
      final notesJson = notes.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(notesJson));

      debugPrint(
        'Note saved: ${note.content.length > 20 ? '${note.content.substring(0, 20)}...' : note.content}',
      );
    } catch (e) {
      debugPrint('Error saving note: $e');
    }
  }

  /// Retrieves all notes for a specific book
  static Future<List<Note>> getNotes(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);

      if (notesJson == null) return [];

      final List<dynamic> notesList = jsonDecode(notesJson);
      final notes = notesList
          .map((json) => Note.fromJson(json))
          .where((note) => note.bookId == bookId)
          .toList();

      return notes;
    } catch (e) {
      debugPrint('Error retrieving notes: $e');
      return [];
    }
  }

  /// Deletes a specific note
  static Future<void> deleteNote(String noteId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);

      if (notesJson == null) return;

      final List<dynamic> notesList = jsonDecode(notesJson);
      final notes = notesList
          .map((json) => Note.fromJson(json))
          .where((note) => note.id != noteId)
          .toList();

      // Save updated list
      final updatedNotesJson = notes.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedNotesJson));

      debugPrint('Note deleted: $noteId');
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }

  /// Updates an existing note
  static Future<void> updateNote(Note updatedNote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notes = await getNotes(updatedNote.bookId);

      // Find and update the note
      final index = notes.indexWhere((n) => n.id == updatedNote.id);
      if (index != -1) {
        notes[index] = updatedNote;

        // Save updated list
        final notesJson = notes.map((n) => n.toJson()).toList();
        await prefs.setString(_storageKey, jsonEncode(notesJson));

        debugPrint('Note updated: ${updatedNote.id}');
      }
    } catch (e) {
      debugPrint('Error updating note: $e');
    }
  }

  /// Clears all notes for a specific book
  static Future<void> clearBookNotes(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString(_storageKey);

      if (notesJson == null) return;

      final List<dynamic> notesList = jsonDecode(notesJson);
      final notes = notesList
          .map((json) => Note.fromJson(json))
          .where((note) => note.bookId != bookId)
          .toList();

      // Save updated list
      final updatedNotesJson = notes.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(updatedNotesJson));

      debugPrint('All notes cleared for book: $bookId');
    } catch (e) {
      debugPrint('Error clearing book notes: $e');
    }
  }
}
