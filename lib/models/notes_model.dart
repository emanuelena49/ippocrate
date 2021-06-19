import 'package:flutter/material.dart';

class Note {
  late int id;
  String title = "";
  String content = "";
  late String color;
}

class NotesModel extends ChangeNotifier {
  int stackIndex = 0;
  List<Note> noteList = [];
  late Note noteBeingEdited;
  late String color;

  void setStackIndex(int inStackIndex){
    stackIndex = inStackIndex;
    notifyListeners();
  }

  void setNoteColor(String inColor){
    color = inColor;
    notifyListeners();
  }

  void loadData(dynamic inDatabaseWorker) async {
    noteList = await inDatabaseWorker.getAll();
    notifyListeners();
  }

}

NotesModel notesModel = NotesModel();