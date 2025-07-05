import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_taking_app/model/note.dart';
import 'package:notes_taking_app/controllers/auth_controller.dart';

class NotesController extends GetxController {
  static NotesController get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Note> _notes = <Note>[].obs;
  final RxList<Note> _filteredNotes = <Note>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxList<String> _categories = [
    'All',
    'General',
    'Work',
    'Personal',
    'Ideas',
  ].obs;

  List<Note> get notes => _notes;
  List<Note> get filteredNotes => _filteredNotes;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;
  List<String> get categories => _categories;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
    ever(_searchQuery, (_) => _filterNotes());
    ever(_selectedCategory, (_) => _filterNotes());
  }

  // Load notes from Firestore
  Future<void> loadNotes() async {
    try {
      _isLoading.value = true;

      if (_authController.user == null) return;

      final querySnapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: _authController.user!.id)
          .orderBy('updatedAt', descending: true)
          .get();

      _notes.value = querySnapshot.docs
          .map((doc) => Note.fromJson(doc.data()))
          .toList();

      _filterNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notes: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Filter notes based on search query and category
  void _filterNotes() {
    List<Note> filtered = _notes;

    // Filter by category
    if (_selectedCategory.value != 'All') {
      filtered = filtered
          .where((note) => note.category == _selectedCategory.value)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.value.isNotEmpty) {
      filtered = filtered
          .where(
            (note) =>
                note.title.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ||
                note.content.toLowerCase().contains(
                  _searchQuery.value.toLowerCase(),
                ) ||
                note.tags.any(
                  (tag) => tag.toLowerCase().contains(
                    _searchQuery.value.toLowerCase(),
                  ),
                ),
          )
          .toList();
    }

    // Sort by pinned first, then by updated date
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    _filteredNotes.value = filtered;
  }

  // Add new note
  Future<void> addNote(
    String title,
    String content, {
    String category = 'General',
    List<String> tags = const [],
  }) async {
    try {
      if (_authController.user == null) {
        Get.snackbar('Error', 'User not authenticated');
        return;
      }

      if (title.trim().isEmpty) {
        Get.snackbar('Error', 'Note title cannot be empty');
        return;
      }

      final noteId = _firestore.collection('notes').doc().id;
      final now = DateTime.now();

      final note = Note(
        id: noteId,
        title: title.trim(),
        content: content.trim(),
        userId: _authController.user!.id,
        createdAt: now,
        updatedAt: now,
        category: category,
        tags: tags,
      );

      await _firestore.collection('notes').doc(noteId).set(note.toJson());

      _notes.insert(0, note);
      _filterNotes();

      Get.snackbar('Success', 'Note added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add note: ${e.toString()}');
    }
  }

  // Update existing note
  Future<void> updateNote(
    String noteId,
    String title,
    String content, {
    String? category,
    List<String>? tags,
  }) async {
    try {
      if (title.trim().isEmpty) {
        Get.snackbar('Error', 'Note title cannot be empty');
        return;
      }

      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex == -1) {
        Get.snackbar('Error', 'Note not found');
        return;
      }

      final existingNote = _notes[noteIndex];
      final updatedNote = existingNote.copyWith(
        title: title.trim(),
        content: content.trim(),
        category: category ?? existingNote.category,
        tags: tags ?? existingNote.tags,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('notes')
          .doc(noteId)
          .update(updatedNote.toJson());

      _notes[noteIndex] = updatedNote;
      _filterNotes();

      Get.snackbar('Success', 'Note updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note: ${e.toString()}');
    }
  }

  // Delete note
  Future<void> deleteNote(String noteId) async {
    try {
      await _firestore.collection('notes').doc(noteId).delete();

      _notes.removeWhere((note) => note.id == noteId);
      _filterNotes();

      Get.snackbar('Success', 'Note deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete note: ${e.toString()}');
    }
  }

  // Toggle pin status
  Future<void> togglePin(String noteId) async {
    try {
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex == -1) return;

      final note = _notes[noteIndex];
      final updatedNote = note.copyWith(
        isPinned: !note.isPinned,
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('notes').doc(noteId).update({
        'isPinned': updatedNote.isPinned,
        'updatedAt': updatedNote.updatedAt.toIso8601String(),
      });

      _notes[noteIndex] = updatedNote;
      _filterNotes();
    } catch (e) {
      Get.snackbar('Error', 'Failed to update note: ${e.toString()}');
    }
  }

  // Search notes
  void searchNotes(String query) {
    _searchQuery.value = query;
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory.value = category;
  }

  // Clear search and filters
  void clearFilters() {
    _searchQuery.value = '';
    _selectedCategory.value = 'All';
  }

  // Add custom category
  void addCategory(String category) {
    if (category.trim().isNotEmpty && !_categories.contains(category.trim())) {
      _categories.add(category.trim());
    }
  }

  // Get notes by category
  List<Note> getNotesByCategory(String category) {
    if (category == 'All') return _notes;
    return _notes.where((note) => note.category == category).toList();
  }

  // Get pinned notes
  List<Note> getPinnedNotes() {
    return _notes.where((note) => note.isPinned).toList();
  }
}
