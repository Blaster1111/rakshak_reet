import 'dart:convert';
import 'package:rakshak_reet/addQDefault.dart';
import 'package:flutter/material.dart';
import 'package:rakshak_reet/addQCustomisable.dart';
import 'package:rakshak_reet/auth/authOption.dart';
import 'package:rakshak_reet/auth/singup.dart';
import 'package:rakshak_reet/homeDesc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = 'https://rakshakrita0.vercel.app/api/authority/station';
  List<dynamic> policeStations = [];
  List<dynamic> filteredStations = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void signOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Clear the user's authentication token
    prefs.remove('authToken');

    // Navigate back to the sign-up page
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SignUp())); // Replace with the appropriate route
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      return;
    }

    print('API URL: $apiUrl');
    print('Authorization Token: $authToken');

    Map<String, String> headers = {
      'authToken': authToken,
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('API Response Status Code: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('API Response: $data');
        if (data.containsKey("stations")) {
          setState(() {
            policeStations = data["stations"];
            filteredStations = List.from(policeStations);
          });
        }
      } else {
        print(
            'API Error - Status Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('API Exception: $e');
    }
  }

  void onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredStations = List.from(policeStations);
      } else {
        filteredStations = policeStations
            .where((station) => station['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _showAddDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 250, 226, 198),
          title: Text('Feedback Form'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Navigate to AddQDefault page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => addQDefault(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange, // Set the color to match your theme
                  fixedSize: Size(200, 40), // Set the width and height
                ),
                child: Text(
                  'Default',
                  style: TextStyle(color: Colors.white), // Text color
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to AddQCustomisable page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddQ(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  fixedSize: Size(200, 40),
                ),
                child: Text(
                  'Customizable',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 226, 198),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 250, 226, 198),
        flexibleSpace: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Row(
              children: [
                Spacer(),
                Text(
                  "Rakshakरीत",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                Spacer(),
                IconButton(
                  color: Colors.black,
                  icon: Icon(
                    Icons.logout,
                    size: MediaQuery.sizeOf(context).height * 0.02,
                  ),
                  onPressed: () {
                    signOut();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: searchBar(onSearch),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStations.length,
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeDesc(
                          stationId: station['_id'],
                          stationName: station['name'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        if (station['qr'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              station['qr'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${station['name']}",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                softWrap: true,
                              ),
                              Text(
                                "${station['area']}, ${station['district']}, ${station['state']}",
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showAddDialog(context);
            },
            backgroundColor: Colors.orange,
            heroTag: null,
            child: Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext) => authOption(),
                ),
              );
            },
            backgroundColor: Colors.orange,
            heroTag: null,
            child: Icon(Icons.person),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  Widget searchBar(Function(String) onSearch) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      shadowColor: const Color(0x55434343),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 20,
              color: Colors.black45,
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onSearch,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
