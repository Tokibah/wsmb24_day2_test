import 'package:d2_wsf24_rider/Home/ridedetail.dart';
import 'package:d2_wsf24_rider/Modal/ride_repo.dart';
import 'package:d2_wsf24_rider/Modal/ridecard_repo.dart';
import 'package:d2_wsf24_rider/Modal/rider_repo.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shake_detector/shake_detector.dart';

class RideCard extends StatefulWidget {
  const RideCard(
      {super.key,
      required this.rideCard,
      required this.refresh,
      required this.isShake,
      required this.user});

  final List<RideCardCreate> rideCard;
  final Rider user;
  final Function() refresh;
  final bool isShake;

  @override
  State<RideCard> createState() => _RideCardState();
}

class _RideCardState extends State<RideCard> {
  late PageController _pageControl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageControl = PageController(initialPage: (widget.rideCard.length ~/ 2));
  }

  void _onShake(BuildContext context, Ride ride) {
    if (widget.isShake) {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
          content: Text('Like the ride?', style: TextStyle(fontSize: 20)),
          actions: [
            TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  Rider.updateLiked(widget.user, ride);
                  widget.refresh();
                },
                child: Text('YES')),
            TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                },
                child: Text('Close'))
          ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      widget.rideCard.isNotEmpty
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              IconButton(
                  onPressed: () {
                    int previous = _pageControl.page!.round() - 1;
                    _pageControl.jumpToPage(
                        previous < 0 ? widget.rideCard.length - 1 : previous);
                  },
                  icon: Icon(Icons.arrow_back_ios_new)),
              SizedBox(
                height: 420.sp,
                width: 300.w,
                child: PageView.builder(
                  itemCount: widget.rideCard.length,
                  controller: _pageControl,
                  itemBuilder: (context, index) {
                    final currentRide = widget.rideCard[index];
                    String formatTime() {
                      final time = TimeOfDay(
                          hour: currentRide.ride.date.hour,
                          minute: currentRide.ride.date.minute);
                      return '${currentRide.ride.date.day}/${currentRide.ride.date.month}/${currentRide.ride.date.year} ${time.format(context)}';
                    }

                    return GestureDetector(
                      onDoubleTap: () => showDialog(
                          context: context,
                          builder: (context) => RideDetail(
                                ridecard: currentRide,
                                rider: widget.user,
                                refresh: widget.refresh,
                              )),
                      child: ShakeDetectWrap(
                        onShake: () => _onShake(context, currentRide.ride),
                        child: Container(
                            margin: EdgeInsets.all(8.sp),
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: EdgeInsets.all(8.sp),
                              child: Column(children: [
                                CircleAvatar(
                                    radius: 50,
                                    backgroundImage: currentRide.driver.image != null
                                        ? NetworkImage(currentRide.driver.image!)
                                        : null),
                                Text(currentRide.driver.name,
                                    style: TextStyle(fontSize: 20.sp)),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                        'Vehicle: ${currentRide.vehicle.name}')),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text('Special Features',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                                Text(
                                  '-${currentRide.vehicle.specFeatures.isNotEmpty ? currentRide.vehicle.specFeatures : 'none'}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Spacer(),
                                Divider(),
                                Text(currentRide.ride.origin),
                                const Icon(Icons.arrow_downward),
                                Text(currentRide.ride.destination),
                                const Divider(color: Colors.grey),
                                Row(children: [
                                  Text(
                                      'Capacity: ${currentRide.ride.rider?.length ?? 0}/${currentRide.vehicle.capacity.round()}'),
                                  Spacer(),
                                  Text(formatTime(),
                                      style: TextStyle(
                                          backgroundColor:
                                              ThemeProvider.popColor))
                                ]),
                                Text(currentRide.ride.fare,
                                    style: TextStyle(fontSize: 20)),
                              ]),
                            )),
                      ),
                    );
                  },
                ),
              ),
              IconButton(
                  onPressed: () {
                    int next = _pageControl.page!.round() + 1;
                    _pageControl
                        .jumpToPage(next >= widget.rideCard.length ? 0 : next);
                  },
                  icon: Icon(Icons.arrow_forward_ios_outlined)),
            ])
          : Center(child: Text('No ride available'))
    ]);
  }
}
