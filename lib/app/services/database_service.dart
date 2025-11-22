import 'package:aplikasi_cbt/app/modules/login/controllers/login_controller.dart';
import 'package:aplikasi_cbt/app/utils/app_material.dart';
import 'package:aplikasi_cbt/app/utils/toast_dialog.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mysql1/mysql1.dart';

class DatabaseService extends GetxService {
  final box = GetStorage();
  static var canLogin = false.obs;

  Future<MySqlConnection> _newConnection() async {
    final settings = ConnectionSettings(
      host: box.read('db_host') ?? 'localhost',
      port: box.read('db_port') ?? 3306,
      user: box.read('db_user') ?? 'root',
      password: box.read('db_pass') ?? '',
      db: box.read('db_name') ?? 'cbt_db',
      timeout: const Duration(seconds: 5),
    );

    return await MySqlConnection.connect(settings);
  }

  Future<bool> testConnection({
    required String host,
    required int port,
    required String user,
    required String password,
    required String dbName,
  }) async {
    print('Menghubungkan ke:');
    print('user: "${user.trim()}"');
    print('password: "${password.trim()}"');
    print('db: "${dbName.trim()}"');
    print('host: "${host.trim()}"');

    MySqlConnection? conn;

    try {
      conn = await MySqlConnection.connect(
        ConnectionSettings(
          host: host,
          port: port,
          user: user,
          password: password,
          db: dbName,
          timeout: const Duration(seconds: 5),
        ),
      );

      await conn.query('SELECT 1');

      canLogin.value = true;
      LoginController.allError.value = "";
      return true;
    } catch (e) {
      ToastService.show(AllMaterial.getErrorMessageFromException(e.toString()));
      LoginController.allError.value =
          "Ada masalah dengan koneksi, periksa konfigurasi & coba lagi nanti!";
      print(e);
      return false;
    } finally {
      try {
        await conn?.close();
      } catch (_) {}
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, [
    List<Object?>? params,
  ]) async {
    MySqlConnection? conn;

    try {
      conn = await _newConnection();

      final results = await conn.query(sql, params ?? []);

      return results.map((row) => row.fields).toList();
    } catch (e) {
      print("❌ Error query: $e");
      rethrow;
    } finally {
      await conn?.close();
    }
  }

  Future<int> execute(
    String sql, [
    List<Object?>? params,
  ]) async {
    MySqlConnection? conn;

    try {
      conn = await _newConnection();

      final result = await conn.query(sql, params ?? []);
      return result.affectedRows ?? 0;
    } catch (e) {
      print("❌ Error execute: $e");
      rethrow;
    } finally {
      await conn?.close();
    }
  }
}
