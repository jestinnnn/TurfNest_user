import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; //date formatting
import 'package:turf_nest/Notifications.dart';
import 'package:turf_nest/booking.dart';
import 'package:turf_nest/firebase_helper/firebase_firestore_helper/firestore_helper.dart';
import 'package:turf_nest/profile.dart';
import 'package:turf_nest/routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TimeOfDay? selectedTime1;
  String? _selectedSport;
  List<String> _sports = [];
  static List<String> disabledDates = ['2024-05-2', '2024-12-25'];
  String? location;
  bool isloading=false;


  Future<void> launchMaps(String destination) async {
    String url =
        'https://www.google.com/maps/dir/?api=1&destination=$destination';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch maps with destination $destination';
    }
  }

  @override
  void initState() {
    super.initState();
    getgames();
  }

  void getgames() async {
    setState(() {
      isloading=true;
    });
    _sports = await FirebaseFirestoreHelper.instance.getAllGames();
    location = await FirebaseFirestoreHelper.instance.getlocation();
    setState(() {
      isloading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double overlapHeight = screenHeight * 0.3;
    double middleHeight = screenHeight * 0.4;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            icon: const Icon(Icons.notifications),
            color: AppColors.white,
            iconSize: 35,
          ),
        ],
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          icon: const Icon(Icons.account_circle_rounded),
          color: AppColors.white,
          iconSize: 35,
        ),
      ),
      body:isloading
          ? Center(
              child: Container(
                color: Colors.white,
                height: 150,
                width: 300,
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 15, 66, 107),
                ),
                alignment: Alignment.center,
              ),
            )
          :  SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              width: screenWidth,
              height: 0.4 * screenHeight,
              child: Container(
                height: middleHeight,
                color: AppColors.blue,
              ),
            ),
            Positioned(
              top: middleHeight - (overlapHeight / 2),
              left: 0.07 * screenWidth,
              right: 0.07 * screenWidth,
              child: Container(
                height: 0.40 * screenHeight,
                width: 0.7 * screenWidth,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Turf Location',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: .01 * screenHeight),
                      ElevatedButton.icon(
                        onPressed: () {
                          launchMaps(location!);
                        },
                        style: ButtonStyles.styleFromWhiteRed(),
                        icon: const Icon(Icons.location_pin),
                        label:  Text(
                          location!,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      const Text('Date',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      SizedBox(height: .01 * screenHeight),
                      Row(
                        children: [
                          ElevatedButton.icon(
                              onPressed: () =>
                                  _selectDate(context, disabledDates),
                              icon: const Icon(Icons.calendar_today),
                              label: const Text(''),
                              style: ButtonStyles.styleFromWhiteRed()),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              selectedDate != null
                                  ? DateFormat('dd-MM-yyyy')
                                      .format(selectedDate!)
                                  : '______',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.red),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Sport',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: .01 * screenHeight),
                          DropdownButtonFormField<String>(
                            value: _selectedSport,
                            items: _sports.map((sport) {
                              return DropdownMenuItem<String>(
                                value: sport,
                                child: Text(sport),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedSport = value;
                              });
                            },
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                  ),
                                ),
                                fillColor: AppColors.red,
                                hintText: 'Choose a sport',
                                labelText: '',
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: const BorderSide(
                                    color: AppColors.red,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(height: .01 * screenHeight),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (_selectedSport != null ||
                                  selectedDate != null) {
                                print('Selected sport: $_selectedSport');
                                Routes.instance.push(
                                    BookingScreen(
                                        date: selectedDate!,
                                        sport: _selectedSport!),
                                    context);
                              } else {
                                print('Please select the sport or the date ');
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                        'Warning',
                                        style: TextStyle(
                                          color: AppColors.red,
                                          fontSize: 18,
                                        ),
                                      ),
                                      content: const Text(
                                        'check the date or sport selected.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            style:
                                ButtonStyles.mainButton(buttonText: 'Submit'),
                            child: const Text('Search'),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(
      BuildContext context, List<String> disabledDates) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        return !disabledDates.contains(_formatDate(date));
      },
    );
    if (pickedDate != null) {
      setState(() {
         selectedDate = pickedDate;
      });
     
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
