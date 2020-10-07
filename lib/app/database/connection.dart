import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';

import 'migrations/migration_v1.dart';
import 'migrations/migration_v2.dart';

class Connection {
  static const DATABASE_NAME = 'TODO_LIST';
  static const VERSION = 1;
  static Connection _instance;
  Database _db;

  final _lock = Lock();

  //*Construtor implementando a forma como irá criar a instancia
  factory Connection() {
    if (_instance == null) {
      //*CRIANDO UMA INSTANCIA
      _instance = Connection._();
    }
    return _instance;
  }

  //*CONSTRUTOR NOMEADO PRIVADO
  Connection._();

  Future<Database> get instance async => await _openConnection();

  Future<Database> _openConnection() async {
    if (_db == null) {
      //* Para processos concorrentes não acessarem no mesmo tempo
      await _lock.synchronized(() async {
        if (_db == null) {
          var databasePath = await getDatabasesPath();
          print(databasePath);
          var pathDatabase = join(databasePath, DATABASE_NAME);
          _db = await openDatabase(
            pathDatabase,
            version: VERSION,
            onConfigure: _onConfigure,
            onCreate: _onCreate,
            onUpgrade: _onUpgrade,
          );
        }
      });
    }
    return _db;
  }

  void closeConnection(){
    //* Verifica se é nulo, se não for, fecha a conexão
    _db?.close();
    _db = null;
  }

  FutureOr<void> _onConfigure(Database db) async {
    //*Verificação para foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  FutureOr<void> _onCreate(Database db, int version) {
    //*Batch => executa varios comandos e só no final da commit
    var batch = db.batch();
    createV1(batch);
    createV2(batch);
    batch.commit();
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) {
    var batch = db.batch();

    //old == 1
    if(oldVersion < 2){
      upgradeV2(batch);
    }

    //old == 2
    if(oldVersion < 3){

    }

    batch.commit();
  }
}
