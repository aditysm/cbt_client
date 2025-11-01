import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseService extends GetxService {
  final box = GetStorage();
  MySqlConnection? _connection;

  Future<MySqlConnection> connect() async {
    if (_connection != null) return _connection!;

    final settings = ConnectionSettings(
      host: box.read('db_host') ?? 'localhost',
      port: box.read('db_port') ?? 3307,
      user: box.read('db_user') ?? 'root',
      password: box.read('db_pass') ?? '',
      db: box.read('db_name') ?? 'cbt_db',
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      return _connection!;
    } catch (e) {
      print("❌ Gagal terhubung ke database: $e");
      rethrow;
    }
  }

  Future<bool> testConnection({
    required String host,
    required int port,
    required String user,
    required String password,
    required String dbName,
  }) async {
    print('Connecting with:');
    print('user: "${user.trim()}"');
    print('password: "${password.trim()}"');
    print('db: "${dbName.trim()}"');
    print('host: "${host.trim()}"');

    try {
      final conn = await MySqlConnection.connect(ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: dbName,
      ));
      await conn.close();
      return true;
    } catch (e) {
      print('Ada masalah ketika tes koneksi: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<Object?>? params,
  ]) async {
    final conn = _connection ?? await connect();

    try {
      final results = await conn.query(sql, params ?? []);
      return results
          .map((row) => {
                for (var i = 0; i < row.length; i++)
                  row.fields.keys.elementAt(i): row[i]
              })
          .toList();
    } catch (e) {
      print(" Error query: $e");
      rethrow;
    }
  }

  Future<int> execute(
    String sql, [
    List<Object?>? params,
  ]) async {
    final conn = _connection ?? await connect();

    try {
      final results = await conn.query(sql, params ?? []);
      return results.affectedRows ?? 0;
    } catch (e) {
      print(" Error execute: $e");
      rethrow;
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
