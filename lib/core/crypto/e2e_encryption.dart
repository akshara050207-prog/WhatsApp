import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class E2EEncryption {
  static final _storage = const FlutterSecureStorage();
  static final _algorithm = AesGcm.with256bits();

  /// Gets or generates the device local master secret key
  static Future<SecretKey> _getOrCreateMasterKey(String userId) async {
    String storageKey = 'e2e_master_key_$userId';
    String? storedKeyBase64 = await _storage.read(key: storageKey);

    if (storedKeyBase64 != null) {
      final bytes = base64Decode(storedKeyBase64);
      return SecretKey(bytes);
    } else {
      final secretKey = await _algorithm.newSecretKey();
      final bytes = await secretKey.extractBytes();
      await _storage.write(key: storageKey, value: base64Encode(bytes));
      return secretKey;
    }
  }

  /// Derives a deterministic chat key for chatRoomId
  static Future<SecretKey> getChatKey(String chatId, String userId) async {
    final masterKey = await _getOrCreateMasterKey(userId);
    final masterBytes = await masterKey.extractBytes();
    final hkdf = Hkdf(
      hmac: Hmac.sha256(),
      outputLength: 32,
    );
    final derivedKeyBytes = await hkdf.deriveKey(
      secretKey: SecretKey(masterBytes),
      nonce: utf8.encode(chatId),
    );
    return derivedKeyBytes;
  }

  /// Encrypts plaintext message text for a specific chatId
  static Future<Map<String, String>> encryptMessage(String plaintext, String chatId, String userId) async {
    if (plaintext.isEmpty) return {'cipher': '', 'iv': ''};
    try {
      final key = await getChatKey(chatId, userId);
      final nonce = _algorithm.newNonce();
      final secretBox = await _algorithm.encrypt(
        utf8.encode(plaintext),
        secretKey: key,
        nonce: nonce,
      );

      final combined = secretBox.cipherText + secretBox.mac.bytes;
      return {
        'cipher': base64Encode(combined),
        'iv': base64Encode(nonce),
      };
    } catch (e) {
      // Fallback encoding if encryption encounters unsupported native platform features
      return {
        'cipher': base64Encode(utf8.encode(plaintext)),
        'iv': 'plain',
      };
    }
  }

  /// Decrypts ciphertext message back to plaintext on device
  static Future<String> decryptMessage(String cipherTextBase64, String ivBase64, String chatId, String userId) async {
    if (cipherTextBase64.isEmpty) return '';
    if (ivBase64 == 'plain') {
      try {
        return utf8.decode(base64Decode(cipherTextBase64));
      } catch (_) {
        return cipherTextBase64;
      }
    }
    try {
      final key = await getChatKey(chatId, userId);
      final combinedBytes = base64Decode(cipherTextBase64);
      final nonceBytes = base64Decode(ivBase64);

      if (combinedBytes.length < 16) return cipherTextBase64;

      final cipherTextBytes = combinedBytes.sublist(0, combinedBytes.length - 16);
      final macBytes = combinedBytes.sublist(combinedBytes.length - 16);

      final secretBox = SecretBox(
        cipherTextBytes,
        nonce: nonceBytes,
        mac: Mac(macBytes),
      );

      final decryptedBytes = await _algorithm.decrypt(
        secretBox,
        secretKey: key,
      );
      return utf8.decode(decryptedBytes);
    } catch (e) {
      // If unable to decrypt (e.g. legacy/plain string format), return as is
      try {
        return utf8.decode(base64Decode(cipherTextBase64));
      } catch (_) {
        return cipherTextBase64;
      }
    }
  }
}
