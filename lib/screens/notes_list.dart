import 'package:flutter/material.dart';
import 'package:ippocrate/db/notes_db_worker.dart';
import 'package:ippocrate/models/notes_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NotesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        onPressed: (){
          notesModel.noteBeingEdited = Note();
          notesModel.setStackIndex(1);
        },
      ),
      body: ListView.builder(
        itemCount: notesModel.noteList.length,
        itemBuilder: (BuildContext inBuildContext, int inIndex){
          Note note = notesModel.noteList[inIndex];
          Color color = Colors.white;
          switch(note.color){
            case "red":
              color = Colors.red;
              break;
            case "blue":
              color = Colors.blue;
              break;
            case "yellow":
              color = Colors.yellow;
              break;
            case "grey":
              color = Colors.grey;
              break;
          }
          return Card(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            elevation: 8,
            child: Slidable(
              actionPane: SlidableScrollActionPane(),
              actionExtentRatio: .25,
              secondaryActions: [
                IconSlideAction(
                  caption: "Delete",
                  color: Colors.red,
                  icon: Icons.delete,
                  onTap: (){
                    _deleteNote(context, note);
                  },
                ),
              ],
              child: ListTile(
                title: Text("${note.title}"),
                subtitle: Text("${note.content}"),
                tileColor: color,
                onTap: () async {
                  notesModel.noteBeingEdited = await NotesDBworker.notesDBworker.get(note.id);
                  notesModel.setNoteColor(notesModel.noteBeingEdited.color);
                  notesModel.setStackIndex(1);
                },
              ),
            ),
          );

        },
      ),
    );
  }

  Future _deleteNote(BuildContext context, Note note) async {
    return showDialog(
        context: context,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext){
          return AlertDialog(
            title: Text("Delete note"),
            content: Text("Are you sure you want to delete ${note.title}"),
            actions: [
              FlatButton(
                  onPressed: (){
                    Navigator.of(inAlertContext).pop();
                  },
                  child: Text("Cancel"),
              ),
              FlatButton(
                  onPressed: () async {
                    await NotesDBworker.notesDBworker.delete(note.id);
                    Navigator.of(inAlertContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text("Note deleted"),
                      ),
                    );
                    notesModel.loadData(NotesDBworker.notesDBworker);
                  },
                  child: Text("Delete"),
              ),
            ],
          );
      }
    );
  }

}