import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d2_wsf24_rider/Modal/driver_repo.dart';
import 'package:d2_wsf24_rider/Modal/ridecard_repo.dart';
import 'package:d2_wsf24_rider/Modal/rider_repo.dart';
import 'package:d2_wsf24_rider/main.dart';
import 'package:flutter/material.dart';

class LikedJoinedPage extends StatefulWidget {
  const LikedJoinedPage({
    super.key,
    required this.rider,
    required this.refresh,
  });

  final Rider rider;
  final Function() refresh;

  @override
  State<LikedJoinedPage> createState() => _LikedJoinedPageState();
}

class _LikedJoinedPageState extends State<LikedJoinedPage> {
  Set<String> _selected = {'Joined'};
  List<RideCardCreate> filtRide = [];
  final ScrollController _scrollController = ScrollController();
  List<RideCardCreate> ridecard = [];
  bool isLoading = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filterRide();
  }

  Future<String?> commentDialog(String drivername) async {
    final _commentControl = TextEditingController();
    return showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Enter your comment for driver $drivername:'),
              content: TextField(controller: _commentControl),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),
                TextButton(
                    onPressed: () =>
                        Navigator.pop(context, _commentControl.text),
                    child: Text('Add'))
              ],
            ));
  }

  void _filterRide() async {
    try {
      setState(() {
        isLoading = true;
      });

      ridecard = await RideCardCreate.createRideCard();
      if (_selected.contains('Liked')) {
        filtRide = ridecard
            .where(
                (r) => widget.rider.likedRide!.any((e) => e.id == r.ride.label))
            .toList();
      } else {
        filtRide = ridecard
            .where((r) =>
                widget.rider.joinRide!.any((e) => e.ownRide.id == r.ride.label))
            .toList();
      }
      isLoading = false;
      setState(() {});
    } catch (e) {
      print('ERROR LIKEJOINFILTER: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _filterRide, icon: Icon(Icons.refresh))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  if (isLoading)
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ]),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 300,
                          child: SegmentedButton(
                            multiSelectionEnabled: false,
                            segments: [
                              ButtonSegment(
                                  value: 'Liked', label: Text('LIKED')),
                              ButtonSegment(
                                  value: 'Joined', label: Text('JOINED'))
                            ],
                            selected: _selected,
                            onSelectionChanged: (select) {
                              setState(() {
                                _selected = select;
                                setState(() {
                                  filtRide = [];
                                });
                                _filterRide();
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 550,
                          child: filtRide.isEmpty
                              ? Center(
                                  child: Text(_selected.contains('Liked')
                                      ? 'No liked ride'
                                      : 'No joined ride'))
                              : ListView.builder(
                                  controller: _scrollController,
                                  itemCount: filtRide.length,
                                  itemBuilder: (context, index) {
                                    final card = filtRide[index];
                                    String payment = '';

                                    final dummyJoinedRide = JoinedRide(
                                      ownRide: FirebaseFirestore.instance
                                          .collection('dummy')
                                          .doc(),
                                      paymentMeth: '',
                                    );
                                    final data = widget.rider.joinRide
                                        ?.firstWhere(
                                            (e) =>
                                                e.ownRide.id == card.ride.label,
                                            orElse: () => dummyJoinedRide);
                                    payment = data!.paymentMeth;

                                    var isLiked = widget.rider.likedRide?.any(
                                            (e) => e.id == card.ride.label) ??
                                        false;

                                    final isJoin = widget.rider.joinRide?.any(
                                            (e) =>
                                                e.ownRide.id ==
                                                card.ride.label) ??
                                        false;

                                    return Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.all(5),
                                      height: 120,
                                      width: 100,
                                      child: Stack(
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      card.driver.image!)),
                                              Text(card.driver.name)
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(children: [
                                                  Text(card.ride.origin),
                                                  Icon(Icons.arrow_downward),
                                                  Text(card.ride.destination),
                                                  Divider(),
                                                  Row(children: [
                                                    Text(payment),
                                                    Spacer(),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      child: Text(
                                                          '${card.ride.date.day}/${card.ride.date.month}/${card.ride.date.year} ${TimeOfDay(hour: card.ride.date.hour, minute: card.ride.date.minute).format(context)}'),
                                                    )
                                                  ])
                                                ]),
                                              ),
                                              Container(
                                                width: 60,
                                                height: double.infinity,
                                                color: ThemeProvider.honeydew,
                                                child: Scrollbar(
                                                  thumbVisibility: true,
                                                  controller: _scrollController,
                                                  child: ListView(
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            if (isLiked) {
                                                              setState(() {
                                                                widget.rider
                                                                    .likedRide
                                                                    ?.removeWhere((e) =>
                                                                        e.id ==
                                                                        card.ride
                                                                            .label);
                                                              });

                                                              Rider.updateLiked(
                                                                  widget.rider,
                                                                  null);
                                                            } else {
                                                              setState(() {
                                                                isLiked = true;
                                                              });
                                                              Rider.updateLiked(
                                                                  widget.rider,
                                                                  card.ride);
                                                            }
                                                            _filterRide();
                                                          },
                                                          icon: Icon(isLiked
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border)),
                                                      IconButton(
                                                          onPressed: () async {
                                                            final result =
                                                                await commentDialog(
                                                                    card.driver
                                                                        .name);
                                                            if (result !=
                                                                    null &&
                                                                result
                                                                    .isNotEmpty) {
                                                              final newCom = Comment(
                                                                  avatar: widget
                                                                      .rider
                                                                      .image!,
                                                                  user: widget
                                                                      .rider
                                                                      .name,
                                                                  content:
                                                                      result);
                                                              card.driver
                                                                  .comment
                                                                  ?.add(newCom);
                                                              Driver.addComment(
                                                                  card.driver);
                                                              await widget
                                                                  .refresh();
                                                            }
                                                          },
                                                          icon: Icon(
                                                              Icons.message)),
                                                      if (isJoin)
                                                        IconButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          AlertDialog(
                                                                            title:
                                                                                Text('Are you sure to cancel ride?'),
                                                                            actions: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('NO')),
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    widget.rider.joinRide?.removeWhere((e) => e.ownRide.id == card.ride.label);
                                                                                    Rider.updateJoined(widget.rider);
                                                                                    _filterRide();
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text('YES'))
                                                                            ],
                                                                          ));
                                                            },
                                                            icon: Icon(
                                                                Icons.cancel)),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                        )
                      ]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
