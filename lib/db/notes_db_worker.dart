import 'package:ippocrate/common/db_worker.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../common/utils.dart' as utils;
import '../models/notes_model.dart';

class NotesDBworker extends DBWorker<Note> {

  NotesDBworker._();
  static final NotesDBworker notesDBworker = NotesDBworker._();

  @override
  Note fromMap(Map<String, dynamic> map) {
    Note note = Note();
    note.id = map["id"];
    note.title = map["title"];
    note.content = map["content"];
    note.color = map["color"];
    return note;
  }

  @override
  Map<String, dynamic> toMap(Note object) {
    Map<String, dynamic> map = Map<String, dynamic>();
    map["id"] = object.id;
    map["title"] = object.title;
    map["content"] = object.content;
    map["color"] = object.color;
    return map;
  }

  @override
  Future create(Note inNote) async {
    Database db = await getDB();
    var val = await db.rawQuery("SELECT MAX(id) + 1 AS id FROM notes");
    int? id = val.first["id"] as int?;
    if (id==null){
      id = 1;
    }
    return await db.rawInsert(
      "INSERT INTO notes (id, title, content, color) "
      "VALUES (?, ?, ?, ?)",
      [id, inNote.title, inNote.content, inNote.color]
    );
  }

  @override
  Future<Note> get(int inID) async {
    Database db = await getDB();
    var rec = await db.query("notes", where: "id = ?", whereArgs: [inID]);
    return fromMap(rec.first);
  }

  @override
  Future<List<Note>> getAll() async {
    Database db = await getDB();
    var recs = await db.query("notes");
    List<Note> list = recs.isEmpty ? [] : recs.map((m) => fromMap(m)).toList();
    return list;
  }

  @override
  Future update(Note inNote) async {
    Database db = await getDB();
    return await db.update("notes", toMap(inNote), where: "id = ?", whereArgs: [inNote.id]);
  }

  @override
  Future delete(int inID) async {
    Database db = await getDB();
    return await db.delete("notes", where: "id = ?", whereArgs: [inID]);
  }



}