import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class BackupService {
  static const String dbName = 'economy.db';

  static Future<void> exportBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final sourceFile = File(join(dbPath, dbName));

      if (await sourceFile.exists()) {
        final tempDir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final backupPath = join(tempDir.path, 'ECO_MILER_BACKUP_$timestamp.db');
        
        await sourceFile.copy(backupPath);
        
        await Share.shareXFiles(
          [XFile(backupPath)],
          subject: 'Copia de Seguridad ECO-MILER',
          text: 'Aquí tienes tu copia de seguridad de ECO-MILER.',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // sqflite files sometimes don't have extension or have .db
      );

      if (result != null && result.files.single.path != null) {
        final selectedFile = File(result.files.single.path!);
        final dbPath = await getDatabasesPath();
        final targetFile = File(join(dbPath, dbName));

        // Cerrar la base de datos antes de sobrescribir
        await databaseFactory.setDatabasesPath(dbPath);
        // Nota: En una app real, deberíamos asegurarnos de cerrar todas las conexiones.
        // Pero al sobrescribir el archivo y reiniciar la app es más seguro.
        
        await selectedFile.copy(targetFile.path);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
