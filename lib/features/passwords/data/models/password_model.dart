import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class PasswordEntry {
  final String id;
  final String title;
  final String username;
  final String encryptedPassword;
  final String url;
  final String note;

  PasswordEntry({
    required this.id,
    required this.title,
    required this.username,
    required this.encryptedPassword,
    this.url = '',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'username': username,
    'encryptedPassword': encryptedPassword,
    'url': url,
    'note': note,
  };

  factory PasswordEntry.fromJson(Map<String, dynamic> json) => PasswordEntry(
    id: json['id'],
    title: json['title'],
    username: json['username'],
    encryptedPassword: json['encryptedPassword'],
    url: json['url'] ?? '',
    note: json['note'] ?? '',
  );
}

class PasswordSecurity {
  static final _key = encrypt.Key.fromLength(32); // In real app, derived from Master PIN
  static final _iv = encrypt.IV.fromLength(16);
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  static String encryptPassword(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }

  static String decryptPassword(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
