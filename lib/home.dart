import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rakshak_reet/addQ.dart';
import 'package:rakshak_reet/homeDesc.dart';
import 'package:rakshak_reet/singup.dart';
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
        // If the search query is empty, show all police stations
        filteredStations = List.from(policeStations);
      } else {
        // Filter the stations based on the search query
        filteredStations = policeStations
            .where((station) => station['name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        flexibleSpace: Center(
          child: Center(
            child: Row(
              children: [
                Spacer(),
                Text(
                  "Rakshakरीत",
                  style: TextStyle(
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
                Spacer(),
                IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.logout), // Add the logout icon
                  onPressed: () {
                    // Perform sign-out logic here
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
          searchBar(onSearch),
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
                                  stationName: station['name'])));
                      // Pushing to description page
                    },
                    child: Card(
                      margin: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Check if 'qr' is not null before displaying the image
                          if (station['qr'] != null)
                            Image.network(
                              station['qr'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${station['name']}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  softWrap:
                                      true, // Allow text to wrap to the next line
                                ),
                                Text(
                                  "${station['area']}, ${station['district']}, ${station['state']}",
                                  softWrap:
                                      true, // Allow text to wrap to the next line
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
          Row(
            children: [
              Spacer(),
              FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => AddQ()));
                },
                backgroundColor:
                    Colors.orange, // Adjust the color to match your app's theme
                child: Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget searchBar(Function(String) onSearch) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      shadowColor: const Color(0x55434343),
      child: TextField(
        onChanged: onSearch,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: "Search",
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black45,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
