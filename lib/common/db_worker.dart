import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'utils.dart' as utils;

class _DBManager {

  _DBManager._();
  static final _DBManager dbManager = _DBManager._();
  Database? _db;

  Future<Database> _getDB({bool forceInit: false}) async {

    if(_db==null){

      // path of sqlite db
      String path = join(utils.docsDir.path, "ippocrate.db");

      if (true) {

        var x = File(path);
        if (await x.exists()) {
          await x.delete();
        }
      }

      bool isInit = false;

      _runInitQuery(Database db) async {

        // get sql for db creation
        String initQuery = (await rootBundle.loadString('assets/ippocrate.sql'))
            .replaceAll("\n", "").replaceAll("\r", "").trim();

        List queries = initQuery.split(';');

        for (String q in queries) {
          if (q != "")  await db.execute(q);
        }

        return;
      }

      _db = await openDatabase(path, version: 1,
          onOpen: (Database inDB) async {

            if(!isInit) await _runInitQuery(inDB);

            var r = await inDB.query('sqlite_master', columns: ['type', 'name']);
            debugPrint(r.toString());
          },
          onCreate: (Database inDB, int inVersion) async {

            await _runInitQuery(inDB);
            isInit = true;
          });
    }
    return _db!;
  }


}

/// A generic interface between a certain data type [T] and the database.
abstract class DBWorker<T> {

  /// Get a built db to operate on it
  Future<Database> getDB() async {
    return await _DBManager.dbManager._getDB();
  }

  /// build an instance of T from a (db) map
  T fromMap(Map<String, dynamic> map);

  /// build an (db format) map from an instance of T
  Map<String, dynamic> toMap(T object);

  /// save a new object in the database
  Future create(T object);

  /// get the object which has a certain id
  Future<T> get(int objectId);

  /// get a list of all the objects
  Future<List<T>> getAll();

  /// update an object in the db
  Future update(T object);

  /// remove an object from the db
  Future delete(int objectId);
}

abstract class HasId {
  int? id;
}

/// A generic interface between a certain data type [T] and the database.
/// It automatizes some actions (if you set some parameters)
abstract class AdvancedDBWorker<K extends HasId> extends DBWorker<HasId> {

  /// the name of a single object of the table (ex. "medicine")
  String get objectName;

  /// the name of the entire table (ex. "medicines").
  /// by default, is [objectName] + "s"
  String get tableName => "${objectName}s";

  /// the name of the field used as id (ex. "medicines").
  /// by default, is [objectName] + "s"
  String get objectIdName => "${objectName}_id";

  @override
  K fromMap(Map<String, dynamic> map);

  @override
  Map<String, dynamic> toMap(object);

  @override
  Future<K> get(int objectId, {String? customQuery}) async {
    Database db = await getDB();

    var rec;
    if (customQuery == null) {
      rec = await db.query(tableName,
          where: "$objectIdName = ?", whereArgs: [objectId]);
    } else {
      rec = await db.rawQuery(customQuery);
    }

    return fromMap(rec.first);
  }

  @override
  Future<List<K>> getAll({String? customQuery}) async {

    Database db = await getDB();

    var recs;

    if (customQuery == null) {
      recs = await db.query(tableName);
    } else {
      recs = await db.rawQuery(customQuery);
    }

    List<K> list = [];
    recs.forEach((element) {
      list.add(fromMap(element));
    });

    return list;
  }

  @override
  Future update(HasId object) async {
    Database db = await getDB();
    return await db.update(tableName, toMap(object),
        where: "$objectIdName = ?",
        whereArgs: [object.id!]);
  }

  @override
  Future delete(int objectId) async {
    Database db = await getDB();
    return await db.delete(tableName,
        where: "$objectIdName = ?",
        whereArgs: [objectId]);
  }

  Future<int> getLastId() async {
    Database db = await getDB();
    return (await db.rawQuery("SELECT last_insert_rowid()"))
        .first["last_insert_rowid()"] as int;
  }
}