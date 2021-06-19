import 'package:flutter/material.dart';
import 'package:ippocrate/db/notes_db_worker.dart';
import 'package:provider/provider.dart';
import '../models/notes_model.dart';
import 'notes_list.dart';
import 'notes_entry.dart';

class Notes extends StatelessWidget {

  Notes() {
    notesModel.loadData(NotesDBworker.notesDBworker);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: notesModel,
      child: Consumer<NotesModel>(
        builder: (context, notesModel, child){
          return IndexedStack(
            index: notesModel.stackIndex,
            children: [NotesList(), NotesEntry()],
          );
        },
      ),
    );
  }
    
}