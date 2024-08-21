import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

import 'package:todo_list/todo.dart';

class DatabaseHelper{
  static final DatabaseHelper _instance = DatabaseHelper();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    return _db;
  }

  Future<Database> iniDb() async{
    io.Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = join(docDirectory.path, 'todolist.db');
    var localDb = await openDatabase(
     path,
     version: 1, onCreate: _onCreate
    );
    return localDb;
  }

  void _onCreate(Database db, int vrsion) async{
    await db.execute('''
    create table if  not exists todo (
    id integer primary key autoincrement,
    nama text not null,
    dpne integer not null default 0
    )''');
  }

  Future<List<Todo>> getALlTodos() async {
    var dbClient = await db;
    var todos = await dbClient!.query('todos');
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<List<Todo>> searchTodo(String keyword) async {
    var dbClient = await db;
    var todos = await dbClient!.query('todos', where: 'nama like ?', whereArgs:['%$keyword%']);
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<int> addTodo(Todo todo) async{
    var dbClient = await db;
    return await dbClient!.insert('todo', todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTodo(Todo todo) async {
    var dbClient = await db;
    return await dbClient!
        .update('todos', todo.toMap(), where:'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async{
    var dbClient = await db;
    return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}