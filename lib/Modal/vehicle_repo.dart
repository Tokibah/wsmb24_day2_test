import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String name;
  final double capacity;
  final String specFeatures;
  final String vLabel;
  List<DocumentReference>? ownRide;

  Vehicle(
      {required this.vLabel,
      required this.name,
      required this.capacity,
      required this.specFeatures,
      this.ownRide});

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
        vLabel: map['vLabel'],
        name: map['name'],
        capacity: map['capacity'],
        specFeatures: map['specFeatures'],
        ownRide: List<DocumentReference>.from(map['ownRide'] ?? []));
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'specFeatures': specFeatures,
      'vLabel': vLabel,
      'ownRide': ownRide,
    };
  }
}
