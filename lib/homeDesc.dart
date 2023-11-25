import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DataModel {
  final String category;
  final double value;
  final Color color;

  DataModel(this.category, this.value, this.color);
}

class FeedbackCategory {
  final String category;
  final double value;
  final Color color;

  FeedbackCategory(this.category, this.value, this.color);
}

class FeedbackCountByDay {
  final DateTime day;
  int count;

  FeedbackCountByDay(this.day, this.count);
}

class HomeDesc extends StatefulWidget {
  final String stationId;
  final String stationName;

  HomeDesc({Key? key, required this.stationId, required this.stationName});

  @override
  State<HomeDesc> createState() => _HomeDescState();
}

class _HomeDescState extends State<HomeDesc> {
  final String apiUrl =
      'https://rakshakrita0.vercel.app/api/authority/feedback';
  double positivePercentage = 0;
  double negativePercentage = 0;
  double neutralPercentage = 0;
  List<dynamic> descriptions = [];
  String stationName = "";
  List<DateTime> createdAtList = [];
  double positiveCountPer = 0.0;
  double negativeCountPer = 0.0;
  double misconductCountPer = 0.0;
  double negligenceCountPer = 0.0;
  double discriminationCountPer = 0.0;
  double corruptedCountPer = 0.0;
  double violationCountPer = 0.0;
  double inefficiencyCountPer = 0.0;
  double unprofessionalConductCountPer = 0.0;
  double responseTimeCountPer = 0.0;
  double usedFirearmsCountPer = 0.0;
  double propertyDamageCountPer = 0.0;
  Map<DateTime, int>? negativeFeedbackCounts;

  List<String> feedbackTypes = [
    'Misconduct',
    'Negligence',
    'Discrimination',
    'Corrupted',
    'Violation of Rights',
    'Inefficiency',
    'Unprofessional Conduct',
    'Response Time',
    'Use of Firearms',
    'Property Damage',
  ];
  String selectedFeedbackType = 'Misconduct';
  List<FeedbackCountByDay> selectedFeedbackCounts = [];
  Map<String, int> feedbackCounts = {
    'Misconduct': 0,
    'Negligence': 0,
    'Discrimination': 0,
    'Corrupted': 0,
    'Violation of Rights': 0,
    'Inefficiency': 0,
    'Unprofessional Conduct': 0,
    'Response Time': 0,
    'Use of Firearms': 0,
    'Property Damage': 0,
  };

  Future<void> updateSelectedFeedbackCounts() async {
    if (negativeFeedbackCounts != null) {
      List<FeedbackCountByDay> updatedCounts = negativeFeedbackCounts!.entries
          .where((entry) =>
              entry.key.isAfter(DateTime(2023, 1, 1)) &&
              entry.key.isBefore(DateTime.now()))
          .map((entry) => FeedbackCountByDay(entry.key, entry.value))
          .toList();

      // Retrieve count for the selected feedback type from feedbackCounts map
      int selectedFeedbackTypeCount = feedbackCounts[selectedFeedbackType] ?? 0;

      // Update counts with the count for the selected feedback type
      updatedCounts.forEach((feedback) {
        feedback.count = selectedFeedbackTypeCount;
      });

      setState(() {
        selectedFeedbackCounts = updatedCounts;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    stationName = widget.stationName;
    fetchData();
    updateSelectedFeedbackCounts(); // Call the fetchData method when the widget is initialized
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      return;
    }

    Map<String, String> headers = {
      'authToken': authToken,
      'Content-Type': 'application/json',
    };

    try {
      final Map<String, dynamic> sendData = {
        'stationId': widget.stationId,
      };
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: json.encode(sendData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print(data);

        if (data.containsKey("feedbacks")) {
          final List<dynamic> feedbacks = data["feedbacks"];
          descriptions = feedbacks.map((feedback) {
            return feedback['description'] ?? 'No description available';
          }).toList();

          createdAtList = feedbacks.map((feedback) {
            return DateTime.parse(feedback['createdAt']);
          }).toList();

          final negativeFeedbacks = feedbacks
              .where((feedback) => feedback['type'] == 'Negative Feedback')
              .toList();

          negativeFeedbackCounts = {};
          negativeFeedbacks.forEach((feedback) {
            final createdAt = DateTime.parse(feedback['createdAt']);
            final dateKey =
                DateTime(createdAt.year, createdAt.month, createdAt.day);

            negativeFeedbackCounts![dateKey] =
                (negativeFeedbackCounts![dateKey] ?? 0) + 1;
          });

          final feedbackCountsList = negativeFeedbackCounts?.entries
                  .map((entry) => FeedbackCountByDay(entry.key, entry.value))
                  .toList() ??
              [];

          // Sort the list by date
          feedbackCountsList.sort((a, b) => a.day.compareTo(b.day));

          int totalFeedbacks = feedbacks.length;

          negativeFeedbacks.forEach((feedback) {
            String issue = feedback['issue'] ?? '';
            if (feedbackCounts.containsKey(issue)) {
              feedbackCounts[issue] = feedbackCounts[issue]! + 1;
            }
          });

          // Calculate the percentages
          int positiveCount = feedbacks
              .where((feedback) => feedback['type'] == 'Positive Feedback')
              .length;
          int negativeCount = feedbacks
              .where((feedback) => feedback['type'] == 'Negative Feedback')
              .length;
          int neutralCount = feedbacks
              .where((feedback) => feedback['type'] == 'Neutral Feedback')
              .length;

          int MisconductCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Misconduct')
              .length;
          int NegligenceCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Negligence')
              .length;
          int DiscriminationCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Discrimination')
              .length;
          int CorruptionCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Corrupted')
              .length;
          int ViolationofRightsCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Violation of Rights')
              .length;
          int InefficiencyCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Inefficiency')
              .length;
          int UnprofessionalConductCount = feedbacks
              .where(
                  (feedback) => feedback['issue'] == 'Unprofessional Conduct')
              .length;
          int ResponseTimeCount = feedbacks
              .where((feedback) => feedback['issue'] == 'Response Time')
              .length;
          int UseofFirearms = feedbacks
              .where((feedback) => feedback['issue'] == 'Use of Firearms')
              .length;
          int PropertyDamage = feedbacks
              .where((feedback) => feedback['issue'] == 'Property Damage')
              .length;

          setState(() {
            positivePercentage = (positiveCount / totalFeedbacks) * 100;
            negativePercentage = (negativeCount / totalFeedbacks) * 100;
            neutralPercentage = (neutralCount / totalFeedbacks) * 100;
            misconductCountPer = (MisconductCount / totalFeedbacks) * 100;
            negligenceCountPer = (NegligenceCount / totalFeedbacks) * 100;
            discriminationCountPer =
                (DiscriminationCount / totalFeedbacks) * 100;
            corruptedCountPer = (CorruptionCount / totalFeedbacks) * 100;
            violationCountPer = (ViolationofRightsCount / totalFeedbacks) * 100;
            inefficiencyCountPer = (InefficiencyCount / totalFeedbacks) * 100;
            unprofessionalConductCountPer =
                (UnprofessionalConductCount / totalFeedbacks) * 100;
            responseTimeCountPer = (ResponseTimeCount / totalFeedbacks) * 100;
            usedFirearmsCountPer = (UseofFirearms / totalFeedbacks) * 100;
            propertyDamageCountPer = (PropertyDamage / totalFeedbacks) * 100;
          });
        } else {
          print(
              'API Error - Status Code: ${response.statusCode}, Body: ${response.body}');
        }
      }
    } catch (e) {
      print('API Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DataModel> data = [
      DataModel('Positive', positivePercentage, Colors.green),
      DataModel('Negative', negativePercentage, Colors.red),
      DataModel('Neutral', neutralPercentage, Colors.grey),
    ];

    final List<FeedbackCategory> columnData = [
      FeedbackCategory("Miscounduct", misconductCountPer, Colors.blue),
      FeedbackCategory("Negligence", negligenceCountPer, Colors.yellow),
      FeedbackCategory("Discriminations", discriminationCountPer, Colors.green),
      FeedbackCategory("Corrupted", corruptedCountPer, Colors.red),
      FeedbackCategory("Violation", violationCountPer, Colors.amber),
      FeedbackCategory("Inefficiency", inefficiencyCountPer, Colors.purple),
      FeedbackCategory(
          "UnprofessionalConduct", unprofessionalConductCountPer, Colors.cyan),
      FeedbackCategory("ResponseTime", responseTimeCountPer, Colors.brown),
      FeedbackCategory("UsedFirearms", usedFirearmsCountPer, Colors.deepOrange),
      FeedbackCategory("PropertyDamage", propertyDamageCountPer, Colors.black),
    ];

    final List<FeedbackCountByDay> feedbackCountsList = negativeFeedbackCounts
            ?.entries
            .map((entry) => FeedbackCountByDay(entry.key, entry.value))
            .toList() ??
        [];
    List<FeedbackCountByDay> filteredFeedbackCountsList = feedbackCountsList
        .where((feedback) =>
            feedback.day.isAfter(DateTime(2023, 1, 1)) &&
            feedback.day.isBefore(DateTime.now()))
        .toList();
    filteredFeedbackCountsList.sort((a, b) => a.day.compareTo(b.day));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        flexibleSpace: Center(
          child: Center(
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
                Text(
                  stationName,
                  style: TextStyle(
                    color: Colors.black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.02,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Feedback Overview",
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              SizedBox(height: 16),
              SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.right,
                ),
                series: <RadialBarSeries<DataModel, String>>[
                  RadialBarSeries<DataModel, String>(
                    dataSource: data,
                    xValueMapper: (DataModel data, _) => data.category,
                    yValueMapper: (DataModel data, _) => data.value,
                    pointColorMapper: (DataModel data, _) => data.color,
                    dataLabelMapper: (DataModel data, _) =>
                        ' ${(data.value).toStringAsFixed(2)}%',
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    innerRadius: '30',
                  ),
                ],
              ),
              Text(
                "Feedback Categories",
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  majorGridLines: MajorGridLines(width: 0.0),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: MajorGridLines(width: 0.0),
                  labelFormat: '{value}%',
                ),
                series: <BarSeries<FeedbackCategory, String>>[
                  BarSeries<FeedbackCategory, String>(
                    dataSource: columnData,
                    xValueMapper: (FeedbackCategory data, _) => data.category,
                    yValueMapper: (FeedbackCategory data, _) => data.value,
                    pointColorMapper: (FeedbackCategory data, _) => data.color,
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.top,
                    ),
                    borderWidth: 2, // Add a border around the bars
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                "Day Wise Negative Feedbacks",
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                primaryYAxis: NumericAxis(
                    title: AxisTitle(text: 'Negative Feedback Count')),
                series: <LineSeries<FeedbackCountByDay, DateTime>>[
                  LineSeries<FeedbackCountByDay, DateTime>(
                    dataSource: filteredFeedbackCountsList,
                    xValueMapper: (FeedbackCountByDay feedback, _) =>
                        feedback.day,
                    yValueMapper: (FeedbackCountByDay feedback, _) =>
                        feedback.count,
                    name: 'Negative Feedback Count',
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: selectedFeedbackType,
                isExpanded: true,
                items: feedbackTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    // Update the selected feedback type when the dropdown changes
                    setState(() {
                      selectedFeedbackType = newValue;
                      updateSelectedFeedbackCounts();
                    });
                  }
                },
              ),
              SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                primaryYAxis: NumericAxis(
                    title: AxisTitle(text: '$selectedFeedbackType Count')),
                series: <LineSeries<FeedbackCountByDay, DateTime>>[
                  LineSeries<FeedbackCountByDay, DateTime>(
                    dataSource: selectedFeedbackCounts,
                    xValueMapper: (FeedbackCountByDay feedback, _) =>
                        feedback.day,
                    yValueMapper: (FeedbackCountByDay feedback, _) =>
                        feedback.count.toDouble(),
                    name: '$selectedFeedbackType Count',
                    markerSettings: MarkerSettings(isVisible: true),
                  ),
                ],
              ),
              Text(
                "Feedbacks",
                style: TextStyle(
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.025,
                ),
              ),
              for (String description in descriptions)
                Card(
                  color: Colors.grey,
                  child: ListTile(
                    title: Text(
                      description,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
