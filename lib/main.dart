import 'package:flutter/material.dart';
import 'package:quizapp/quiz.dart';
import 'package:quizapp/result.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quizapp/loginscreen.dart';
import 'package:quizapp/storagedata.dart'; // Ensure this is available for storing/retrieving score

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter quiz app',
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class quizHomePage extends StatefulWidget {
  const quizHomePage({super.key});

  @override
  State<quizHomePage> createState() => _quizHomePageState();
}

class _quizHomePageState extends State<quizHomePage> {
  final ScoreStorage score = ScoreStorage(); // Initialize ScoreStorage here
  final _studentIdController = TextEditingController();
  int _lastScore = 0;
  bool _takeQuiz = true;

  @override
  void initState() {
    super.initState();
    _loadScore();
    _getStudentId();
    _checkStudentIdInPrefs();
  }

  // Load the score when the page is initialized
  void _loadScore() async {
    int storedScore = await score.readScore();
    setState(() {
      _lastScore = storedScore;
    });
  }

  // Check if the student ID is saved and if the quiz can be taken
  _checkStudentIdInPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool present = prefs.containsKey('studentId');
    setState(() {
      _takeQuiz = present;
    });
  }

  // Get the student ID from SharedPreferences
  _getStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String studentId = prefs.getString('studentId') ?? '';
    setState(() {
      _studentIdController.text = studentId;
    });
  }

  // Save the student ID to SharedPreferences
  _addUserDetailstoSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('studentId', _studentIdController.text);
  }

  // Navigate to the quiz screen and retrieve the score
  _navigateAndDisplayScore(BuildContext context) async {
    // Assuming the Quiz class returns a Map with quiz results
    Map<String, dynamic> quizResults = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(),
      ),
    );

    // Assuming the quiz returns these values
    int returnedScore = quizResults['score'] ?? 0;
    int totalQuestions = quizResults['totalQuestions'] ?? 0;
    int answered = quizResults['answered'] ?? 0;
    int unanswered = quizResults['unanswered'] ?? 0;

    // Navigate to the ResultPage with the quiz results
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          totalQuestions: totalQuestions,
          answered: answered,
          unanswered: unanswered,
          score: returnedScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Icon(Icons.account_box, size: 22),
              ),
              TextSpan(
                text: " Quiz Profile",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange[400],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height + 200,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10.00),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Last Quiz Score: $_lastScore",
                  style: TextStyle(fontSize: 24)),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (this._takeQuiz) {
                          _navigateAndDisplayScore(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please submit your details first!',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepOrange[400]),
                      ),
                      child: Text(
                        "Take Quiz",
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 80.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
