import 'package:flutter/material.dart';
import 'package:ippocrate/db/notes_db_worker.dart';
import 'package:ippocrate/models/notes_model.dart';

class NotesEntry extends StatelessWidget{

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
        child: Row(
          children: [
            FlatButton(
                onPressed: (){
                  notesModel.setStackIndex(0);
                },
                child: Text("Cancel"),
            ),
            Spacer(),
            FlatButton(
                onPressed: (){
                  _save(context);
                },
                child: Text("Save"),
            ),
          ],
        )
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.title),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Title"),
                initialValue: notesModel.noteBeingEdited == null ? null : notesModel.noteBeingEdited.title,
                validator: (String inValue){
                  if(inValue.length==0){
                    return "Please enter a title";
                  }
                  return null;
                },
                onChanged: (String inValue){
                  notesModel.noteBeingEdited.title = inValue;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.content_paste),
              title: TextFormField(
                decoration: InputDecoration(hintText: "Content"),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                initialValue: notesModel.noteBeingEdited == null ? null : notesModel.noteBeingEdited.content,
                validator: (String inValue){
                  if(inValue.length==0){
                    return "Please enter content";
                  }
                  return null;
                },
                onChanged: (String inValue){
                  notesModel.noteBeingEdited.content = inValue;
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.color_lens),
              title: Row(
                children: [
                  GestureDetector(
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: Border.all(
                          color: Colors.red,
                          width: 18,
                        ) + Border.all(
                              width: 6,
                              color: notesModel.color == "red" ? Colors.red : Theme.of(context).canvasColor,
                            )
                      ),
                    ),
                    onTap: (){
                      notesModel.noteBeingEdited.color = "red";
                      notesModel.setNoteColor("red");
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      decoration: ShapeDecoration(
                          shape: Border.all(
                            color: Colors.blue,
                            width: 18,
                          ) + Border.all(
                            width: 6,
                            color: notesModel.color == "blue" ? Colors.blue : Theme.of(context).canvasColor,
                          )
                      ),
                    ),
                    onTap: (){
                      notesModel.noteBeingEdited.color = "blue";
                      notesModel.setNoteColor("blue");
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      decoration: ShapeDecoration(
                          shape: Border.all(
                            color: Colors.yellow,
                            width: 18,
                          ) + Border.all(
                            width: 6,
                            color: notesModel.color == "yellow" ? Colors.yellow : Theme.of(context).canvasColor,
                          )
                      ),
                    ),
                    onTap: (){
                      notesModel.noteBeingEdited.color = "yellow";
                      notesModel.setNoteColor("yellow");
                    },
                  ),
                  Spacer(),
                  GestureDetector(
                    child: Container(
                      decoration: ShapeDecoration(
                          shape: Border.all(
                            color: Colors.grey,
                            width: 18,
                          ) + Border.all(
                            width: 6,
                            color: notesModel.color == "grey" ? Colors.grey : Theme.of(context).canvasColor,
                          )
                      ),
                    ),
                    onTap: (){
                      notesModel.noteBeingEdited.color = "grey";
                      notesModel.setNoteColor("grey");
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  void _save(BuildContext context) async {

    if(!_formKey.currentState.validate()){
      return;
    }

    //_formKey.currentState.save();

    if(notesModel.noteBeingEdited.id==null){
      await NotesDBworker.notesDBworker.create(notesModel.noteBeingEdited);
    } else {
      await NotesDBworker.notesDBworker.update(notesModel.noteBeingEdited);
    }

    notesModel.loadData(NotesDBworker.notesDBworker);
    
    notesModel.setStackIndex(0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
        content: Text("Note saved"),
      ),
    );

  }

}