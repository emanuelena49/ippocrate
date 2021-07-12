import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ippocrate/common/has_notes.dart';
import 'package:ippocrate/common/model.dart';

class NotesInput extends StatelessWidget {

  HasNotes obj;
  Model model;

  NotesInput({required this.obj, required this.model});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: (obj.notes == null) ?
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.black54,
        ),
        child: Text("Aggiungi Nota"),
        onPressed: () {
          obj.notes = "";
          model.notify();
        },
      ) :
      TextFormField(
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          border: UnderlineInputBorder(),
          alignLabelWithHint: true,
          labelText: "Scrivi nota",
          hintText: "ex. Da prendere solo dopo i pasti",
        ),
        maxLines: 4,
        initialValue: obj.notes!,
        validator: (inValue) {
          return null;
        },
        onChanged: (inValue) {
          obj.notes = inValue;
        },
        /*
        onSaved: (inValue) {
          if (inValue=="") {
            obj.notes = null;
            model.notify();
          }
        },*/
      ),
    );
  }
}