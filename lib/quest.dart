import 'package:flutter/material.dart';

class Question extends StatelessWidget {
  final String questionText;
  final String questionNo;

  Question(this.questionText, this.questionNo);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 20.0), // Add some padding for spacing
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the content
        children: [
          Text(
            'Q$questionNo',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[400],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            questionText,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
