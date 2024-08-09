import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d2_wsf24_rider/Modal/driver_repo.dart';
import 'package:d2_wsf24_rider/Modal/ride_repo.dart';
import 'package:d2_wsf24_rider/Modal/vehicle_repo.dart';

class RideCardCreate {
  final Driver driver;
  final Vehicle vehicle;
  final Ride ride;

  RideCardCreate({required this.driver, required this.vehicle, required this.ride});

  static final _firestrore = FirebaseFirestore.instance;

  static Future<List<RideCardCreate>> createRideCard() async {
    List<RideCardCreate> rideCardList = [];

    final allRide = await Ride.getRide();

    for (int i = 0; i < allRide.length; i++) {
      final ridePath = _firestrore.collection('Ride').doc(allRide[i].label);

      final getVehicle = await _firestrore
          .collection('Vehicle')
          .where('ownRide', arrayContains: ridePath)
          .get();
      final realVehicle = Vehicle.fromMap(getVehicle.docs.first.data());
      final vehiclePath =
          _firestrore.collection('Vehicle').doc(realVehicle.vLabel);

      final getDriver = await _firestrore
          .collection('Driver')
          .where('ownVehicle', isEqualTo: vehiclePath)
          .get();
      final realDriver = Driver.fromMap(getDriver.docs.first.data());

      final tempCard =
          RideCardCreate(driver: realDriver, vehicle: realVehicle, ride: allRide[i]);
      rideCardList.add(tempCard);
    }
    return rideCardList;
  }
}
