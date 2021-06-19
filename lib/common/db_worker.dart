import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'utils.dart' as utils;

class _DBManager {

  _DBManager._();
  static final _DBManager dbManager = _DBManager._();
  late Database _db;

  Future<Database> _getDB({bool forceInit: false}) async {
    if(_db==null){

      // path of sqlite db
      String path = join(utils.docsDir.path, "ippocrate.db");

      // get sql for db creation
      String initQuery = (await rootBundle.loadString('assets/ippocrate.sql'))
          .replaceAll("\n", "").replaceAll("\r", "");

      _db = await openDatabase(path, version: 1,
          onOpen: (Database inDB) async {
            await inDB.execute(initQuery);
          },
          onCreate: (Database inDB, int inVersion) async {
            // await inDB.execute(initQuery);
          });
    }
    return _db;
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
  Future<K> get(int objectId) async {
    Database db = await getDB();
    var rec = await db.query(tableName,
        where: "$objectIdName = ?", whereArgs: [objectId]);
    return fromMap(rec.first);
  }

  @override
  Future<List<K>> getAll() async {
    Database db = await getDB();
    var recs = await db.query(tableName);

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
}