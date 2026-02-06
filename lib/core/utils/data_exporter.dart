import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class DataExporter {
  static Future<void> exportToJson(String fileName, List<Map<String, dynamic>> data) async {
    final jsonString = jsonEncode(data);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName.json');
    await file.writeAsString(jsonString);
    
    await Share.shareXFiles([XFile(file.path)], text: 'Exported $fileName');
  }

  static Future<List<dynamic>?> importFromJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      return jsonDecode(content);
    }
    return null;
  }

  static String prettyEncode(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static String encodeData(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  static List<dynamic> decodeData(String jsonString) {
    return jsonDecode(jsonString);
  }
}
