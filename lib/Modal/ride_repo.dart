import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final DateTime date;
  final String origin;
  final String destination;
  final String fare;
  final List<String>? rider;
  final String label;

  Ride(
      {required this.date,
      required this.origin,
      required this.destination,
      required this.fare,
      this.rider,
      required this.label});

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
        date: DateTime.parse(map['date']),
        origin: map['origin'],
        destination: map['destination'],
        fare: map['fare'],
        rider: map['rider'] != null ? List<String>.from(map['rider']) : null,
        label: map['label']);
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toString(),
      'origin': origin,
      'destination': destination,
      'fare': fare,
      'rider': rider,
      'label': label,
    };
  }

  static Future<List<Ride>> getRide() async {
    try {
      final rideList =
          await FirebaseFirestore.instance.collection('Ride').get();
      return rideList.docs.map((map) => Ride.fromMap(map.data())).toList();
    } catch (e) {
      print('ERROR GETRIDE: $e');
      return [];
    }
  }

}

class RideRider {
  final String name;
  final bool pre;

  RideRider({required this.name, required this.pre});
}
