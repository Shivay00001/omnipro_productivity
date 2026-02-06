import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';
import 'dart:typed_data';

class EncryptionUtils {
  static String hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Basic AES implementation for Password Manager
  static Uint8List encryptAES(String plainText, String key) {
    // Implementation placeholder for production-ready AES
    return Uint8List.fromList(utf8.encode(plainText)); 
  }

  static String decryptAES(Uint8List encryptedData, String key) {
    // Implementation placeholder
    return utf8.decode(encryptedData);
  }
}
