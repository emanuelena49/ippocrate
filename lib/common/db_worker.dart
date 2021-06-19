import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'utils.dart' as utils;

class _DBManager {

  _DBManager._();
  static final _DBManager dbManager = _DBManager._();
  Database _db;

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