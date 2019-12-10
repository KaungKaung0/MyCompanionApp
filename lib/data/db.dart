import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableAccounts = 'account';
final String columnId = 'id';
final String columnName = 'name';
final String columnAmount = 'amount';
final String columnFinal = 'finalamount';

// data model class
class Account {
  int id;
  String name;
  int amount;
  int finalamount;

  Account();

  // convenience constructor to create a Word object
  Account.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    amount = map[columnAmount];
    finalamount = map[columnFinal];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnAmount: amount,
      columnFinal: finalamount
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableAccounts (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnAmount INTEGER NOT NULL,
                $columnFinal INTEGER NOT NULL
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(Account account) async {
    Database db = await database;
    int id = await db.insert(tableAccounts, account.toMap());
    return id;
  }

  queryAccountList() async {
    Database db = await database;
    var list = await db.query(tableAccounts);
    List<Account> accountsList =
        list.isNotEmpty ? list.map((c) => Account.fromMap(c)).toList() : [];
    return accountsList;
  }
}

queryLastAmount(int rowId) async {
  int lastamount;
  // get a reference to the database
  Database db = await DatabaseHelper.instance.database;

  // get single row
  List<String> columnsToSelect = [
    columnId,
    columnName,
    columnAmount,
    columnFinal
  ];
  String whereString = 'id = ?';
  List<dynamic> whereArguments = [rowId];
  List<Map> result = await db.query(tableAccounts,
      columns: columnsToSelect, where: whereString, whereArgs: whereArguments);
  if (result.isEmpty) {
    lastamount = 0;
    print("FIrst time ");
    return lastamount;
  } else {
    result.forEach((f) => print(f));
    Map<String, dynamic> mapRead = result.first;
    int lastamount = mapRead['finalamount'];
    print(lastamount);
    return lastamount;
  }
}

// get all data by list
readAll() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Account> account = await helper.queryAccountList();
  print(account.length);
  return account.length;
}

//Get the last amount of data;
getLastAmount() async {
  int lastRow = await readAll();
  int lastamount = await queryLastAmount(lastRow);
  print("Last Amount $lastamount.");
  return lastamount;
}

save(String name, int amount) async {
  int lastRow;
  int lastamount;
  lastRow = await readAll();
  if (lastRow == 0) {
    print("its first time");
    Account account = Account();
    account.name = name;
    account.amount = amount;
    account.finalamount = amount;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(account);
    print('inserted row: $id');
  } else {
    print("Data existed");
    lastamount = await getLastAmount() as int;
    Account account = Account();
    account.name = name;
    account.amount = amount;
    account.finalamount = amount + lastamount;
    DatabaseHelper helper = DatabaseHelper.instance;
    int id = await helper.insert(account);
    print('inserted row: $id');
  }
}

// update(String name, int amount) async {
//   int lastamount;
//   lastamount = await getLastAmount();
//   if (lastamount == 0) lastamount = 0;
//   int updateAmount = lastamount + amount;
//   Account updateAccount = Account();
//   updateAccount.name = name;
//   updateAccount.amount = amount;
//   updateAccount.finalamount = updateAmount;
//   DatabaseHelper helper = DatabaseHelper.instance;
//   await helper.updateMainBalance(updateAccount);
// }
