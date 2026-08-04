import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/user_model.dart';

class RegisteredContactMatch {
  final UserModel userModel;
  final String contactName;

  RegisteredContactMatch({required this.userModel, required this.contactName});
}

class ContactsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Clean & normalize phone numbers to last 10 digits for matching
  static String normalizePhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return digits.substring(digits.length - 10);
    }
    return digits;
  }

  /// Request contacts permission and match registered NexTalk users
  static Future<Map<String, dynamic>> fetchAndMatchContacts() async {
    List<RegisteredContactMatch> registered = [];
    List<Contact> unregistered = [];

    var status = await Permission.contacts.request();
    if (!status.isGranted) {
      // Permission not granted
      return {'registered': registered, 'unregistered': unregistered, 'permissionDenied': true};
    }

    try {

      List<Contact> contacts = await FlutterContacts.getAll();
      QuerySnapshot userSnapshot = await _firestore.collection('users').get();

      Map<String, UserModel> phoneToUserMap = {};
      for (var doc in userSnapshot.docs) {
        var userData = doc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(userData, doc.id);
        if (user.phone.isNotEmpty) {
          String normalized = normalizePhone(user.phone);
          if (normalized.isNotEmpty) {
            phoneToUserMap[normalized] = user;
          }
        }
      }

      for (var contact in contacts) {
        if (contact.phones.isEmpty) continue;
        bool isMatched = false;
        for (var phoneObj in contact.phones) {
          String norm = normalizePhone(phoneObj.number);
          if (norm.isNotEmpty && phoneToUserMap.containsKey(norm)) {
            final displayName = contact.displayName;
            final userModel = phoneToUserMap[norm]!;
            registered.add(RegisteredContactMatch(
              userModel: userModel,
              contactName: (displayName != null && displayName.isNotEmpty) ? displayName : userModel.displayName,
            ));
            isMatched = true;
            break;
          }
        }

        if (!isMatched) {
          unregistered.add(contact);
        }
      }
    } catch (e) {
      print("Contacts matching error: $e");
    }

    return {
      'registered': registered,
      'unregistered': unregistered,
      'permissionDenied': false,
    };
  }
}
