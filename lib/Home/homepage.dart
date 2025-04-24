import 'package:d2_wsf24_rider/Home/likedjoinedpage.dart';
import 'package:d2_wsf24_rider/Home/ridecard.dart';
import 'package:d2_wsf24_rider/Modal/ridecard_repo.dart';
import 'package:d2_wsf24_rider/Modal/rider_repo.dart';
import 'package:d2_wsf24_rider/Welcome/launchscreen.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userId});

  final String? userId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool notLoading = false;
  bool isShake = true;
  Rider? rider;
  List<RideCardCreate> rideCard = [];
  List<RideCardCreate> filtCard = [];

  DateTime? dateFilter;
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getRideData();
  }

  Future<void> getRideData() async {
    rider = await Rider.fetchRider(widget.userId);
    rideCard = await RideCardCreate.createRideCard();
    await _applyFilter();
    setState(() {
      notLoading = true;
    });
  }

  Future<void> _applyFilter() async {
    filtCard = rideCard.where((e) {
      if (rider?.joinRide != null) {
        return !rider!.joinRide!.any((r) => r.ownRide.id == e.ride.label);
      }
      return false; 
    }).toList();

    if (_originController.text.isNotEmpty) {
      filtCard = filtCard
          .where((ridecard) => ridecard.ride.origin
              .toLowerCase()
              .contains(_originController.text.toLowerCase()))
          .toList();
    }
    if (_destinationController.text.isNotEmpty) {
      filtCard = filtCard
          .where((ridecard) => ridecard.ride.destination
              .toLowerCase()
              .contains(_destinationController.text.toLowerCase()))
          .toList();
    }
    if (dateFilter != null) {
      filtCard = filtCard
          .where((ridecard) =>
              ridecard.ride.date.year == dateFilter!.year &&
              ridecard.ride.date.month == dateFilter!.month &&
              ridecard.ride.date.day == dateFilter!.day)
          .toList();
    }
    setState(() {});
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _autoDesign(
      {required String hint,
      required TextEditingController controller,
      required FocusNode focusNode}) {
    return Padding(
      padding: EdgeInsets.all(5.sp),
      child: SizedBox(
        width: 180.sp,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: InputDecoration(
              filled: true,
              fillColor: ThemeProvider.lightColor,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              hintText: hint),
          onSubmitted: (value) {
            controller.text = value;
            _applyFilter();
          },
        ),
      ),
    );
  }

  Future<void> _logOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LaunchScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (notLoading) {
      return Scaffold(
        appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                  onTap: () {
                    showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(0, 80, 80, 0),
                        items: [
                          PopupMenuItem(value: 0, child: Text('LOG OUT'))
                        ]).then((value) {
                      if (value != null) {
                        _logOut();
                      }
                    });
                  },
                  child: CircleAvatar(
                      backgroundImage: NetworkImage(rider?.image ?? ''))),
            ),
            title: Text('KONGSI KERETA'),
            automaticallyImplyLeading: false,
            backgroundColor: ThemeProvider.honeydew,
            actions: [
              IconButton(onPressed: getRideData, icon: Icon(Icons.refresh)),
            ]),
        body: Column(children: [
          Container(
            margin: EdgeInsets.all(8),
            color: ThemeProvider.honeydew,
            child: Column(children: [
              Wrap(children: [
                Autocomplete<RideCardCreate>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) {
                      _originController.text = '';
                      return const Iterable.empty();
                    }
                    final dupli = <String>{};
                    return rideCard.where((ridecard) {
                      final origin = ridecard.ride.origin.toLowerCase();

                      if (origin.contains(textValue.text.toLowerCase()) &&
                          dupli.add(origin)) {
                        return true;
                      }
                      return false;
                    }).toList();
                  },
                  displayStringForOption: (option) => option.ride.origin,
                  onSelected: (ride) {
                    _originController.text = ride.ride.origin;
                    _applyFilter();
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      _autoDesign(
                    focusNode: focusNode,
                    hint: 'Origin...',
                    controller: textEditingController,
                  ),
                ),
                Autocomplete<RideCardCreate>(
                  optionsBuilder: (textValue) {
                    if (textValue.text.isEmpty) {
                      _destinationController.text = '';
                      return const Iterable.empty();
                    }
                    final dupli = <String>{};
                    return rideCard.where((ridecard) {
                      final destin = ridecard.ride.destination.toLowerCase();

                      if (destin.contains(textValue.text.toLowerCase()) &&
                          dupli.add(destin)) {
                        return true;
                      }
                      return false;
                    }).toList();
                  },
                  displayStringForOption: (option) => option.ride.destination,
                  onSelected: (option) {
                    _destinationController.text = option.ride.destination;
                    _applyFilter();
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                          onFieldSubmitted) =>
                      _autoDesign(
                          focusNode: focusNode,
                          hint: 'Destination...',
                          controller: textEditingController),
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 200.sp,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeProvider.lightColor),
                      onPressed: () async {
                        dateFilter = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030));
                        _applyFilter();
                      },
                      child: Text(dateFilter == null
                          ? "Filter Date"
                          : _formatDate(dateFilter!))),
                ),
                if (dateFilter != null)
                  IconButton(
                      onPressed: () => setState(() {
                            dateFilter = null;
                            _applyFilter();
                          }),
                      icon: const Icon(Icons.cancel)),
              ])
            ]),
          ),
          RideCard(
              rideCard: filtCard,
              refresh: getRideData,
              isShake: isShake,
              user: rider!)
        ]),
        bottomNavigationBar: Container(
          color: ThemeProvider.honeydew,
          height: 70,
          child: GestureDetector(
            onTap: () async {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              setState(() {
                isShake = false;
              });

              await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LikedJoinedPage(
                      refresh: getRideData,
                      rider: rider!,
                    ),
                  ));
              setState(() {
                isShake = true;
              });
            },
            child: Center(
                child: Text(
                    'ACTIVITY${rider!.joinRide!.isEmpty ? '' : '(${rider!.joinRide?.length})'}',
                    style: TextStyle(fontSize: 20))),
          ),
        ),
      );
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }
}
