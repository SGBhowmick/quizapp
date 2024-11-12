import 'package:flutter/material.dart';
import 'package:quizapp/quiz.dart'; // Import the quiz page
import 'package:quizapp/main.dart'; // Import the home page
import 'package:quizapp/storagedata.dart'; // Ensure the ScoreStorage is imported

class ResultPage extends StatelessWidget {
  final int totalQuestions;
  final int answered;
  final int unanswered;
  final int score;

  ResultPage({
    required this.totalQuestions,
    required this.answered,
    required this.unanswered,
    required this.score,
  });

  // Save the score using ScoreStorage
  void _saveScore(int score) async {
    ScoreStorage scoreStorage = ScoreStorage();
    await scoreStorage.writeScore(score); // Save the score to SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage
    double percentage = (score / totalQuestions) * 100;

    // Save the score when the page is built
    _saveScore(score);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Your Performance"),
        backgroundColor: Colors.pinkAccent[400],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dashboard Overview
            Text(
              "Quiz Dashboard",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[600],
              ),
            ),
            SizedBox(height: 20),

            // Performance Summary
            Card(
              elevation: 5.0,
              color: Colors.indigo[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Questions: $totalQuestions",
                        style: TextStyle(fontSize: 18)),
                    Text("Answered: $answered", style: TextStyle(fontSize: 18)),
                    Text("Unanswered: $unanswered",
                        style: TextStyle(fontSize: 18)),
                    Text("Your Score: $score", style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text(
                      "Percentage: ${percentage.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 50 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Navigation Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        quizHomePage(), // Navigate to home page
                  ),
                );
              },
              child: Text("Go to Dashboard"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 14, horizontal: 50)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to restart the quiz or take it again
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Quiz(),
                  ),
                );
              },
              child: Text("Retake Quiz"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange[400]),
                padding: MaterialStateProperty.all(
                    EdgeInsets.symmetric(vertical: 14, horizontal: 50)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
