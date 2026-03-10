import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileStorage {
  Future<Directory> _baseDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final base = Directory(p.join(directory.path, 'patients'));
    if (!await base.exists()) {
      await base.create(recursive: true);
    }
    return base;
  }

  Future<String> savePatientFile({
    required int patientId,
    required File source,
    required String prefix,
  }) async {
    final base = await _baseDir();
    final extension = p.extension(source.path);
    final filename = '${prefix}_$patientId${extension.isEmpty ? '' : extension}';
    final dest = File(p.join(base.path, filename));
    if (await dest.exists()) {
      await dest.delete();
    }
    final saved = await source.copy(dest.path);
    return saved.path;
  }

  Future<void> deleteFile(String? path) async {
    if (path == null || path.isEmpty) {
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
