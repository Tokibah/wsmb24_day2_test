import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:d2_wsf24_rider/Modal/ride_repo.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Rider {
  final String name;
  final String icNumber;
  final String gender;
  String? phone;
  final String email;
  final String address;
  String? image;
  String? password;
  final String idLabel;
  final List<DocumentReference>? likedRide;
  List<JoinedRide>? joinRide;

  Rider(
      {this.likedRide,
      required this.name,
      required this.icNumber,
      required this.gender,
      this.phone,
      required this.email,
      required this.address,
      this.image,
      this.password,
      this.joinRide,
      required this.idLabel});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icNumber': icNumber,
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'image': image,
      'password': password,
      'joinRide': joinRide 
          ?.map((r) => {
                'ownRide': r.ownRide,
                'paymentMeth': r.paymentMeth,
              })
          .toList(),
      'likedRide': likedRide,
      'idLabel': idLabel
    };
  }

  factory Rider.fromMap(Map<String, dynamic> map) {
    return Rider(
        name: map['name'] ?? '',
        icNumber: map['icNumber'] ?? '',
        gender: map['gender'] ?? '',
        phone: map['phone'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
        image: map['image'] ?? '',
        password: map['password'],
        joinRide: map['joinRide'] != null
            ? List<JoinedRide>.from(
                (map['joinRide'] as List).map((r) => JoinedRide(
                      ownRide: r['ownRide'] ?? '',
                      paymentMeth: r['paymentMeth'] ?? '',
                    )))
            : [],
        likedRide: List<DocumentReference>.from(map['likedRide'] ?? []),
        idLabel: map['idLabel'] ?? '');
  }

  static final _firestore = FirebaseFirestore.instance;

  static Future<Rider?> fetchRider(String? label) async {
    try {
      final collect = await _firestore.collection('Rider').doc(label).get();
      return Rider.fromMap(collect.data()!);
    } catch (e) {
      print('ERROR FETCHRIDER: $e');
      return null;
    }
  }

  static Future<void> addRider(Rider driver) async {
    try {
      final byte = utf8.encode(driver.password!);
      final hashed = sha256.convert(byte).toString();
      driver.password = hashed;

      await _firestore
          .collection('Rider')
          .doc(driver.idLabel)
          .set(driver.toMap());
    } catch (e) {
      print('ADDRIDER ERROR: $e');
    }
  }

  static Future<void> uploadImage(File? image, String id) async {
    try {
      final uploadTask = FirebaseStorage.instance
          .ref('images/${DateTime.now().microsecondsSinceEpoch}.jpg')
          .putFile(image!);

      final snapshot = await uploadTask;
      final dowloadUrl = await snapshot.ref.getDownloadURL();
      await _firestore
          .collection('Rider')
          .doc(id)
          .update({'image': dowloadUrl});
    } catch (e) {
      print('ERROR UPLOADIMAGE: $e');
    }
  }

  static Future<void> updateLiked(Rider rider, Ride? ride) async {
    try {
      if (ride != null) {
        final rideSnap = _firestore.collection('Ride').doc(ride.label);
        rider.likedRide?.add(rideSnap);
      }

      await _firestore
          .collection('Rider')
          .doc(rider.idLabel)
          .update({'likedRide': rider.likedRide});
    } catch (e) {
      print('ERROR UPDATEDRIVER: $e');
    }
  }

  static Future<void> updateJoined(Rider rider) async {
    final joinedMap = rider.joinRide
        ?.map((e) => {'ownRide': e.ownRide, 'paymentMeth': e.paymentMeth})
        .toList();

    await _firestore
        .collection('Rider')
        .doc(rider.idLabel)
        .update({'joinRide': joinedMap});
  }

  static Future<String> logIn(String givenIc, String givenPass) async {
    final byte = utf8.encode(givenPass);
    final hash = sha256.convert(byte).toString();

    try {
      final collect = await _firestore
          .collection('Rider')
          .where('icNumber', isEqualTo: givenIc)
          .where('password', isEqualTo: hash)
          .get();

      if (collect.docs.isEmpty) {
        return '';
      }

      final logRider = Rider.fromMap(collect.docs.first.data());

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', logRider.idLabel);

      return logRider.idLabel;
    } catch (e) {
      print('LOGIN ERROR: $e');
      return '';
    }
  }

  static Future<bool> checkDupli(String newIc, String newPhone) async {
    final queries = [
      _firestore.collection('Rider').where('icNumber', isEqualTo: newIc).get(),
      _firestore.collection('Rider').where('phone', isEqualTo: newPhone).get(),
    ];

    final snap = await Future.wait(queries);

    return snap.any((querysnap) => querysnap.docs.isNotEmpty);
  }
}

class JoinedRide {
  final DocumentReference ownRide;
  final String paymentMeth;

  JoinedRide({required this.ownRide, required this.paymentMeth});
}
