import 'package:sqflite/sqflite.dart';

void createV2(Batch batch){
  batch.execute('''
    create table teste(id integer)
  ''');
}

void upgradeV2(Batch batch){
   batch.execute('''
    create table teste(id integer)
  ''');
}