// edit_template.dart

import 'package:flutter/material.dart';

class addQDefault extends StatefulWidget {
  @override
  _addQDefaultState createState() => _addQDefaultState();
}

class _addQDefaultState extends State<addQDefault> {
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    questions = [
      {
        'questionType': 'Short Answer',
        'question': 'Type your short answer here',
        'options': [],
      },
      {
        'questionType': 'Short Answer',
        'question': 'Type your short answer here',
        'options': [],
      },
      {
        'questionType': 'MCQ',
        'question': 'What is your favorite color?',
        'options': ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
      },
      {
        'questionType': 'MCQ',
        'question': 'What is your favorite animal?',
        'options': ['Dog', 'Cat', 'Bird', 'Other'],
      },
    ];
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
              "Default Feedback Form",
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (int i = 0; i < questions.length; i++)
              QuestionInput(
                question: questions[i],
                onQuestionUpdated: (question) {
                  setState(() {
                    questions[i] = question;
                  });
                },
              ),
            ElevatedButton(
                onPressed: () => {},
                child: Text(
                  "Update",
                )),
          ],
        ),
      ),
    );
  }

  void updateTemplate() {
    print('Updated Template: $questions');
  }
}

typedef QuestionUpdatedCallback = void Function(Map<String, dynamic>);

class QuestionInput extends StatefulWidget {
  final Map<String, dynamic> question;
  final QuestionUpdatedCallback onQuestionUpdated;

  QuestionInput({required this.question, required this.onQuestionUpdated});

  @override
  _QuestionInputState createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  TextEditingController questionController = TextEditingController();
  TextEditingController option1Controller = TextEditingController();
  TextEditingController option2Controller = TextEditingController();
  TextEditingController option3Controller = TextEditingController();
  TextEditingController option4Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    questionController.text = widget.question['question'];
    // Set option controllers with existing values or default values
    option1Controller.text = widget.question['options'].isNotEmpty
        ? widget.question['options'][0]
        : 'Option 1';
    option2Controller.text = widget.question['options'].length > 1
        ? widget.question['options'][1]
        : 'Option 2';
    option3Controller.text = widget.question['options'].length > 2
        ? widget.question['options'][2]
        : 'Option 3';
    option4Controller.text = widget.question['options'].length > 3
        ? widget.question['options'][3]
        : 'Option 4';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white, // Set the background color to white
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Type: ${widget.question['questionType']}',
              style: TextStyle(fontSize: 18.0)),
          Text('Question', style: TextStyle(fontSize: 18.0)),
          TextField(
            controller: questionController,
            onChanged: (value) {
              widget.onQuestionUpdated({
                'questionType': widget.question['questionType'],
                'question': value,
                'options': [
                  option1Controller.text,
                  option2Controller.text,
                  option3Controller.text,
                  option4Controller.text,
                ],
              });
            },
            decoration: InputDecoration(
              hintText: 'Question',
            ),
          ),
          if (widget.question['questionType'] == 'MCQ') ...[
            Text('Options', style: TextStyle(fontSize: 18.0)),
            buildOptionTextField(option1Controller, 'Option 1'),
            buildOptionTextField(option2Controller, 'Option 2'),
            buildOptionTextField(option3Controller, 'Option 3'),
            buildOptionTextField(option4Controller, 'Option 4'),
          ],
        ],
      ),
    );
  }

  Widget buildOptionTextField(
      TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      onChanged: (value) {
        widget.onQuestionUpdated({
          'questionType': widget.question['questionType'],
          'question': questionController.text,
          'options': [
            option1Controller.text,
            option2Controller.text,
            option3Controller.text,
            option4Controller.text,
          ],
        });
      },
      decoration: InputDecoration(
        hintText: hintText,
      ),
    );
  }
}
