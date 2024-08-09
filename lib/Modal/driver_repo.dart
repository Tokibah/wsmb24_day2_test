import 'package:cloud_firestore/cloud_firestore.dart';

class Driver {
  final String name;
  final List<Comment>? comment;
  final String gender;
  String phone;
  final String email;
  final String address;
  String? image;

  final String idLabel;
  DocumentReference? ownVehicle;

  Driver(
      {required this.name,
      this.comment,
      required this.gender,
      required this.phone,
      required this.email,
      required this.address,
      this.image,
      this.ownVehicle,
      required this.idLabel});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'comment':
          comment?.map((e) => {'user': e.user, 'content': e.content}).toList(),
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'image': image,
      'ownVehicle': ownVehicle,
      'idLabel': idLabel
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
        name: map['name'],
        comment: map['comment'] != null
            ? List<Comment>.from((map['comment'] as List).map((r) => Comment(
                avatar: r['avatar'], user: r['user'], content: r['content'])))
            : [],
        gender: map['gender'],
        phone: map['phone'],
        email: map['email'],
        address: map['address'],
        image: map['image'],
        ownVehicle: map['ownVehicle'],
        idLabel: map['idLabel']);
  }

  static Future<void> addComment(Driver driver) async {
    try {
      final comMap = driver.comment
          ?.map((e) => {'avatar': e.avatar, 'user': e.user, 'content': e.content})
          .toList();

      await FirebaseFirestore.instance
          .collection('Driver')
          .doc(driver.idLabel)
          .update({'comment': comMap});
    } catch (e) {
      print('ADDCOMMENT ERROR: $e');
    }
  }
}

class Comment {
  final String user;
  final String avatar;
  final String content;

  Comment({required this.avatar, required this.user, required this.content});
}
