import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddQDefault extends StatefulWidget {
  late final String stationId; // Mark it as final

  AddQDefault({required this.stationId});

  @override
  _AddQState createState() => _AddQState();
}

class _AddQState extends State<AddQDefault> {
  List<String> types = ['Short Answer', 'MCQ'];
  List<Map<String, dynamic>> questions = [];
  final String apiUrl = 'https://rakshakrita0.vercel.app/api/authority/form';
  List<String> selectedStationId = ['sbi', 'star', 'cedar', 'idea', 'eec'];
  String successMessage = '';
  TextEditingController questionController = TextEditingController();
  int selectedStationIndex = 0;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    fetchFormData();
  }

  void submitForm() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      return;
    }

    List<Map<String, dynamic>> postData = questions.map((question) {
      return {
        'questionType': question['questionType'],
        'question': question['question'],
        'options': question['questionType'] == 'MCQ' ? question['options'] : [],
        'stationId': widget.stationId,
      };
    }).toList();
    print(postData);

    Map<String, String> headers = {
      'authToken': authToken,
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'fields': postData,
      'stationId': "sbi",
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('POST Request Status Code: ${response.statusCode}');
      print('POST Request Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          successMessage = 'Form submitted successfully';
          editingIndex = null;
        });
      } else {
        setState(() {
          successMessage = 'Form submission failed';
        });
      }
    } catch (e) {
      setState(() {
        successMessage = 'Form submission exception: $e';
      });
    }
  }

  void fetchFormData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      return;
    }

    Map<String, String> headers = {
      'authToken': authToken,
    };
    Map<String, String> body = {
      'stationId': selectedStationId[selectedStationIndex],
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      print('GET Request Status Code: ${response.statusCode}');
      print('GET Request Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic>? responseBody = json.decode(response.body);
        if (responseBody != null && responseBody.containsKey('form')) {
          List<Map<String, dynamic>> responseData =
              List<Map<String, dynamic>>.from(responseBody['form']['fields']);
          setState(() {
            questions = responseData;
          });
        } else {
          print('Invalid response structure');
        }
      } else {
        print('GET Request failed');
      }
    } catch (e) {
      print('GET Request exception: $e');
    }
  }

  void _editQuestion(int index) {
    setState(() {
      editingIndex = index;
      questionController.text = questions[index]['question'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 250, 226, 198),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromARGB(255, 250, 226, 198),
        flexibleSpace: Center(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
            child: Text(
              "Default Feedback Form",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<int>(
                value: selectedStationIndex,
                onChanged: (int? selectedIndex) {
                  if (selectedIndex != null) {
                    setState(() {
                      selectedStationIndex = selectedIndex;
                      fetchFormData();
                    });
                  }
                },
                items: ['sbi', 'star', 'cedar', 'idea', 'eec']
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  String station = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(station),
                  );
                }).toList(),
              ),
              QuestionList(
                questions: questions,
                onEdit: _editQuestion,
                editingIndex: editingIndex,
                questionController: questionController,
                onSave: () {
                  setState(() {
                    questions[editingIndex!]['question'] =
                        questionController.text;
                    editingIndex = null;
                    submitForm();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuestionList extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int index) onEdit;
  final int? editingIndex;
  final TextEditingController questionController;
  final VoidCallback onSave;

  const QuestionList({
    Key? key,
    required this.questions,
    required this.onEdit,
    required this.editingIndex,
    required this.questionController,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Questions:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
        ),
        for (int i = 0; i < questions.length; i++)
          Card(
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: editingIndex == i
                  ? TextFormField(
                      controller: questionController,
                      decoration:
                          InputDecoration(labelText: 'Edit your question'),
                    )
                  : Text(questions[i]['question']),
              subtitle: Text('Type: ${questions[i]['questionType']}'),
              trailing: editingIndex == i
                  ? ElevatedButton(
                      onPressed: () {
                        onSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: Text('Save'),
                    )
                  : IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        onEdit(i);
                      },
                    ),
            ),
          ),
      ],
    );
  }
}
