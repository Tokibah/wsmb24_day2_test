import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d2_wsf24_rider/Modal/driver_repo.dart';
import 'package:d2_wsf24_rider/Modal/ride_repo.dart';
import 'package:d2_wsf24_rider/Modal/ridecard_repo.dart';
import 'package:d2_wsf24_rider/Modal/rider_repo.dart';
import 'package:d2_wsf24_rider/Modal/vehicle_repo.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RideDetail extends StatefulWidget {
  const RideDetail(
      {super.key,
      required this.ridecard,
      required this.rider,
      required this.refresh});

  final RideCardCreate ridecard;
  final Rider rider;
  final Function() refresh;

  @override
  State<RideDetail> createState() => _RideDetailState();
}

class _RideDetailState extends State<RideDetail> {
  final _formkey = GlobalKey<FormState>();
  String? _paymethod;
  late Driver driver;
  late Vehicle car;
  late Ride ride;

  @override
  void initState() {
    super.initState();
    driver = widget.ridecard.driver;
    car = widget.ridecard.vehicle;
    ride = widget.ridecard.ride;
    setState(() {});
  }

  Widget listTile({required IconData icon, required String content}) {
    return Flexible(
      child: SizedBox(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            icon,
            color: ThemeProvider.trustColor,
          ),
          Text(content, style: TextStyle(overflow: TextOverflow.ellipsis))
        ]),
      ),
    );
  }

  String formatTime() {
    final time = TimeOfDay(hour: ride.date.hour, minute: ride.date.minute);
    return '${ride.date.day}/${ride.date.month}/${ride.date.year} ${time.format(context)}';
  }

  void _joinRide() {
    final path = FirebaseFirestore.instance.collection('Ride').doc(ride.label);
    final JoinedRide newJoined =
        JoinedRide(ownRide: path, paymentMeth: _paymethod!);
    widget.rider.joinRide!.add(newJoined);
    Rider.updateJoined(widget.rider);
    widget.refresh();
    Navigator.pop(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: ThemeProvider.honeydew,
        child: Container(
            margin: EdgeInsets.all(8.sp),
            child: Padding(
              padding: EdgeInsets.all(8.sp),
              child: Form(
                key: _formkey,
                child: Column(children: [
                  CircleAvatar(
                      radius: 50, backgroundImage: NetworkImage(driver.image!)),
                  Text(driver.name, style: TextStyle(fontSize: 20.sp)),
                  Wrap(children: [
                    listTile(icon: Icons.email, content: driver.email),
                    listTile(icon: Icons.pin_drop, content: driver.address),
                    listTile(icon: Icons.person, content: driver.gender),
                    listTile(icon: Icons.phone, content: driver.phone),
                  ]),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Vehicle: ${car.name}')),
                  Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Special Features',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Text(
                    '-${car.specFeatures.isNotEmpty ? car.specFeatures : 'none'}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text('comments',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                        itemCount: driver.comment?.length ?? 0,
                        itemBuilder: (context, index) => Container(
                              decoration: BoxDecoration(
                                  color: ThemeProvider.lightColor,
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(5)),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(3.sp),
                                    child: Row(children: [
                                      CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              driver.comment![index].avatar)),
                                      Text(driver.comment![index].user,
                                          style: TextStyle(fontSize: 20.sp)),
                                    ]),
                                  ),
                                  Text(
                                      '\t\t\t-${driver.comment![index].content}')
                                ],
                              ),
                            )),
                  ),
                  Divider(),
                  Text(ride.origin),
                  const Icon(Icons.arrow_downward),
                  Text(ride.destination),
                  const Divider(color: Colors.grey),
                  Row(children: [
                    Text(
                        'Capacity: ${ride.rider?.length ?? 0}/${car.capacity.round()}'),
                    Spacer(),
                    Text(formatTime(),
                        style:
                            TextStyle(backgroundColor: ThemeProvider.popColor))
                  ]),
                  Text(ride.fare, style: TextStyle(fontSize: 20)),
                  Spacer(),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: ThemeProvider.lightColor,
                        border: OutlineInputBorder(),
                        labelText: 'Choose payment method...'),
                    value: _paymethod,
                    items: [
                      DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                      DropdownMenuItem(
                          value: 'DuitNow', child: Text('DuitNow')),
                      DropdownMenuItem(
                          value: 'TnG wallet', child: Text('TnG wallet'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _paymethod = value!;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Dont leave empthy' : null,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _joinRide();
                        }
                      },
                      child: Text('JOIN'))
                ]),
              ),
            )));
  }
}
