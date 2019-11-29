import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableAccounts = 'account';
final String columnId = '_id';
final String columnName = 'name';
final String columnAmount = 'amount';
final String columnFinal = 'finalammount';

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
  static final _databaseVersion = 3;

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

  Future<Account> queryMainAccount(int id) async {
    Database db = await database;
    List<Map> maps =
        await db.query(tableAccounts, where: '$columnId = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return Account.fromMap(maps.first);
    }
    return null;
  }

  queryAccount() async {
    Database db = await database;
    var list = await db.query(tableAccounts);
    List<Account> accountsList =
        list.isNotEmpty ? list.map((c) => Account.fromMap(c)).toList() : [];
    return accountsList;
  }

  Future<Account> updateMainBalance(Account newaccount) async {
    Database db = await database;
    await db.update(tableAccounts, newaccount.toMap(),
        where: "id = ?", whereArgs: [newaccount.id]);
    return null;
  }
}

// get all data by list
readAll() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Account> account = await helper.queryAccount();
  return account;
}

//read only first row data which will always update;
getLastAmount() async {
  DatabaseHelper helper = DatabaseHelper.instance;
  List<Account> allList = await helper.queryAccount();
  int id = allList.length;
  var lastamount;
  if (id == 0 || null) {
    lastamount = 0;
    return lastamount;
  } else {
    Account account = await helper.queryMainAccount(id);
    var lastamount = account.finalamount;
    return lastamount;
  }
}

save(String name, int amount) async {
  var lastamount = await getLastAmount();
  if (lastamount == null) lastamount = 0;
  Account account = Account();
  account.name = name;
  account.amount = amount;
  account.finalamount = lastamount;
  DatabaseHelper helper = DatabaseHelper.instance;
  int id = await helper.insert(account);
  update(name, amount);
  print('inserted row: $id');
}

update(String name, int amount) async {
  var lastamount = await getLastAmount();
  if (lastamount == 0) lastamount = 0;
  int updateAmount = lastamount + amount;
  Account updateAccount = Account();
  updateAccount.name = name;
  updateAccount.amount = amount;
  updateAccount.finalamount = updateAmount;
  DatabaseHelper helper = DatabaseHelper.instance;
  await helper.updateMainBalance(updateAccount);
}
