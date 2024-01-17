import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AddQ extends StatefulWidget {
  @override
  _AddQState createState() => _AddQState();
}

class _AddQState extends State<AddQ> {
  List<String> types = ['Short Answer', 'MCQ'];
  List<Map<String, dynamic>> questions = [];
  final String apiUrl = 'https://rakshakrita0.vercel.app/api/authority/form';

  String successMessage = '';
  String selectedQuestionForDeletion =
      ''; // Variable to store the selected question for deletion

  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFormData();
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
            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Text(
              "Customisable Feedback Form",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height * 0.04,
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
              QuestionInput(
                questionTypes: types,
                onQuestionAdded: (type, question, options) {
                  print('Type: $type, Question: $question, Options: $options');
                  questions.add({
                    'questionType': type,
                    'question': question,
                    'options': options,
                  });
                },
                onSubmitForm: submitForm,
              ),
              SizedBox(height: 16.0), // Add some spacing
              Divider(height: 1, color: Colors.grey), // Add a divider
              SizedBox(height: 16.0), // Add some spacing
              QuestionList(
                questions: questions,
                deleteQuestion: deleteQuestion,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle floating action button press
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add),
      ),
    );
  }

  void updateQuestion(int index, String field, dynamic value) {
    setState(() {
      questions[index][field] = value;
    });
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
      };
    }).toList();

    Map<String, String> headers = {
      'authToken': authToken,
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> body = {
      'fields': postData,
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

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      print('GET Request Status Code: ${response.statusCode}');
      print('GET Request Body: ${response.body}');

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> responseData =
            List<Map<String, dynamic>>.from(
                json.decode(response.body)['form']['fields']);
        setState(() {
          questions = responseData;
        });
      } else {
        print('GET Request failed');
      }
    } catch (e) {
      print('GET Request exception: $e');
    }
  }

  void deleteQuestion(int index) async {
    selectedQuestionForDeletion = questions[index]['question'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');
    Map<String, String> headers = {
      'authToken': authToken!,
      'Content-Type': 'application/json',
    };

    setState(() {
      questions.removeAt(index);
    });

    try {
      List<Map<String, dynamic>> updatedQuestions =
          List<Map<String, dynamic>>.from(questions);
      updatedQuestions.removeWhere(
          (question) => question['question'] == selectedQuestionForDeletion);

      Map<String, dynamic> updatedBody = {'fields': updatedQuestions};

      final postResponse = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(updatedBody),
      );

      if (postResponse.statusCode == 200) {
        print('Question deleted successfully from backend.');
      } else {
        print('Failed to delete question from backend.');
      }
    } catch (e) {
      print('Exception during question deletion: $e');
    }
  }
}

typedef QuestionAddedCallback = void Function(String, String, List<String>);

class QuestionInput extends StatefulWidget {
  final List<String> questionTypes;
  final QuestionAddedCallback onQuestionAdded;
  final VoidCallback onSubmitForm;

  QuestionInput({
    required this.questionTypes,
    required this.onQuestionAdded,
    required this.onSubmitForm,
  });

  @override
  _QuestionInputState createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  TextEditingController questionController = TextEditingController();
  bool showOptions = false;
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();
  String selectedQuestionType = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Type', style: TextStyle(fontSize: 18.0)),
          DropdownButton<String>(
            value:
                selectedQuestionType.isNotEmpty ? selectedQuestionType : null,
            onChanged: (String? value) {
              setState(() {
                selectedQuestionType = value ?? '';
                showOptions = value == 'MCQ';
              });
            },
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('Select Type'),
              ),
              ...widget.questionTypes.map((String e) {
                return DropdownMenuItem<String>(
                  value: e,
                  child: Text(e),
                );
              }).toList(),
            ],
          ),
          Text(
              'Selected Question Type: ${selectedQuestionType.isNotEmpty ? selectedQuestionType : 'Select Type'}'),
          Text('Question', style: TextStyle(fontSize: 18.0)),
          TextField(
            controller: questionController,
            decoration: InputDecoration(
              hintText: 'Question',
            ),
          ),
          if (showOptions) ...[
            Text('Options', style: TextStyle(fontSize: 18.0)),
            TextField(
              controller: option1Controller,
              decoration: InputDecoration(
                hintText: 'Option 1',
              ),
            ),
            TextField(
              controller: option2Controller,
              decoration: InputDecoration(
                hintText: 'Option 2',
              ),
            ),
            TextField(
              controller: option3Controller,
              decoration: InputDecoration(
                hintText: 'Option 3',
              ),
            ),
            TextField(
              controller: option4Controller,
              decoration: InputDecoration(
                hintText: 'Option 4',
              ),
            ),
          ],
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              if (selectedQuestionType.isEmpty ||
                  selectedQuestionType == 'Select Type') {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Error"),
                      content: Text("Please select a valid question type"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("OK"),
                        ),
                      ],
                    );
                  },
                );
                return;
              }

              if (showOptions) {}
              widget.onQuestionAdded(
                selectedQuestionType,
                questionController.text,
                [
                  option1Controller.text,
                  option2Controller.text,
                  option3Controller.text,
                  option4Controller.text,
                ],
              );

              widget.onSubmitForm();

              questionController.clear();
              option1Controller.clear();
              option2Controller.clear();
              option3Controller.clear();
              option4Controller.clear();

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Success"),
                    content: Text("Question uploaded successfully"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.orange, // Set the background color to orange
            ),
            child: Text('Add Question'),
          ),
        ],
      ),
    );
  }
}

class Question extends StatelessWidget {
  final Map<String, dynamic> el;
  final int index;
  final Function(int) deleteQuestion; // Add this line
  final Function(int, String, dynamic) updateQuestion;
  final List<String> questionTypes;

  Question({
    required this.el,
    required this.index,
    required this.deleteQuestion, // Add this line
    required this.updateQuestion,
    required this.questionTypes,
  });

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Type', style: TextStyle(fontSize: 18.0)),
          Text(el['questionType'] ?? '',
              style: TextStyle(fontStyle: FontStyle.italic)),
          SizedBox(height: 8.0),
          Text('Question', style: TextStyle(fontSize: 18.0)),
          Text(el['question'] ?? ''),
          if (el['questionType'] == 'MCQ')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text('Options', style: TextStyle(fontSize: 18.0)),
                // ... existing code ...
              ],
            ),
          SizedBox(height: 8.0),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Call the deleteQuestion method here
              deleteQuestion(index);
            },
          ),
        ],
      ),
    );
  }
}

class QuestionList extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int) deleteQuestion;

  QuestionList({required this.questions, required this.deleteQuestion});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Question(
                el: questions[index],
                index: index,
                deleteQuestion: deleteQuestion,
                updateQuestion: (index, field, value) {},
                questionTypes: [],
              );
            },
          ),
        ],
      ),
    );
  }
}
