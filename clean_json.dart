import 'dart:convert';
import 'dart:io';

void main() async {
  final directory = Directory('assets/data');
  if (!directory.existsSync()) {
    stdout.writeln('❌ Directory assets/data not found! Run this from project root.');
    return;
  }

  final files = directory
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'));
  if (files.isEmpty) {
    stdout.writeln('⚠️ No JSON files found in assets/data/');
    return;
  }

  for (final file in files) {
    stdout.writeln('🔄 Processing ${file.path}...');
    try {
      final content = file.readAsStringSync();
      final data = jsonDecode(content);

      dynamic clean(dynamic obj) {
        if (obj is Map) {
          final newMap = <String, dynamic>{};
          for (final entry in obj.entries) {
            final cleanKey = (entry.key as String).trim();
            newMap[cleanKey] = clean(entry.value);
          }
          return newMap;
        } else if (obj is List) {
          return obj.map((e) => clean(e)).toList();
        } else if (obj is String) {
          return obj.trim();
        }
        return obj;
      }

      final cleanedData = clean(data);
      final encoder = JsonEncoder.withIndent('  ');
      file.writeAsStringSync(encoder.convert(cleanedData));
      stdout.writeln('✅ Cleaned: ${file.path.split('/').last}');
    } catch (e) {
      stdout.writeln('❌ Error in ${file.path}: $e');
    }
  }
  stdout.writeln('\n🎉 All JSON files cleaned! You can now delete this script.');
}
