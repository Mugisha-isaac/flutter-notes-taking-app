import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notes_taking_app/controllers/note_controller.dart';
import 'package:notes_taking_app/model/note.dart';

class AddEditNotePage extends StatefulWidget {
  final Note? note;

  const AddEditNotePage({super.key, this.note});

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final NotesController notesController = Get.find<NotesController>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  late String selectedCategory;
  List<String> tags = [];
  final TextEditingController tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
    selectedCategory = widget.note?.category ?? 'General';
    tags = List.from(widget.note?.tags ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();
    super.dispose();
  }

  bool get isEditing => widget.note != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Note Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              maxLines: 1,
            ),
            const SizedBox(height: 16),

            // Category Selection
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: notesController.categories
                  .map((category) {
                    if (category == 'All') return null;
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  })
                  .where((item) => item != null)
                  .cast<DropdownMenuItem<String>>()
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Tags Section
            const Text(
              'Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Add Tag Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(tagController.text),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Display Tags
            if (tags.isNotEmpty)
              Wrap(
                spacing: 8.0,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 18),
                    onDeleted: () {
                      setState(() {
                        tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // Content Field
            TextField(
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Note Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 10,
              textAlignVertical: TextAlignVertical.top,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                if (isEditing)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: _deleteNote,
                    ),
                  ),
                if (isEditing) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(isEditing ? 'Update' : 'Save'),
                    onPressed: _saveNote,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.trim().isNotEmpty && !tags.contains(tag.trim())) {
      setState(() {
        tags.add(tag.trim());
        tagController.clear();
      });
    }
  }

  void _saveNote() {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a note title');
      return;
    }

    if (isEditing) {
      notesController.updateNote(
        widget.note!.id,
        titleController.text,
        contentController.text,
        category: selectedCategory,
        tags: tags,
      );
    } else {
      notesController.addNote(
        titleController.text,
        contentController.text,
        category: selectedCategory,
        tags: tags,
      );
    }

    Get.back();
  }

  void _deleteNote() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              notesController.deleteNote(widget.note!.id);
              Get.back(); // Close dialog
              Get.back(); // Close edit page
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
