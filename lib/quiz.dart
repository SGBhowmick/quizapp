import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:quizapp/result.dart';

class Quiz extends StatefulWidget {
  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List _questions = [];
  int _totalScore = 0;
  List<int> _currScore = [];
  List<String> _currAns = [];
  String _character = '';
  late Timer _questionTimer;
  int _remainingTime = 30; // Timer duration for each question
  List<bool> _answeredQuestions = []; // To track answered questions
  List<bool> _questionTimedOut = []; // To track which questions timed out
  late PageController _pageController; // To control the page view
  int _questionIndex = 0;
  Set<int> _attendedQuestions = Set(); // Set to track answered questions

  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Load questions when the widget is initialized
    _pageController = PageController(
        initialPage: _questionIndex); // Initialize PageController
  }

  // Load the questions.json file
  Future<void> _loadQuestions() async {
    String jsonString = await rootBundle.loadString('assets/questions.json');
    final jsonResponse = jsonDecode(jsonString);
    setState(() {
      _currScore = List.filled(jsonResponse['questions'].length, 0);
      _currAns = List.filled(jsonResponse['questions'].length, '');
      _answeredQuestions = List.filled(jsonResponse['questions'].length,
          false); // Initializing answered tracking
      _questionTimedOut = List.filled(jsonResponse['questions'].length,
          false); // Initializing timed out tracking
      _questions = jsonResponse['questions'];
    });

    // Start a timer for the first question
    _startQuestionTimer();
  }

  // Start a timer for the current question
  void _startQuestionTimer() {
    _remainingTime = _questions[_questionIndex]['timer'] ?? 30;

    _questionTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        setState(() {
          _questionTimedOut[_questionIndex] = true;
        });
        _nextQuestion();
      }
    });
  }

  // Handle answering a question
  void _answerQuestion() {
    if (_currAns[_questionIndex].isNotEmpty) {
      _totalScore +=
          _currScore[_questionIndex]; // Add score based on selected answer
      _answeredQuestions[_questionIndex] = true; // Mark question as answered
      _attendedQuestions.add(_questionIndex); // Add question to attended set
    }
    _nextQuestion();
  }

  void _skipQuestion() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to skip this question?'),
          content: Text('You will not be able to go back to this question.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _nextQuestion(); // Skip to the next question
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  // Move to the next question
  void _nextQuestion() {
    _questionTimer.cancel();
    if (_questionIndex >= _questions.length - 1) {
      // Once all questions are answered, navigate to ResultPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            totalQuestions: _questions.length,
            answered: _attendedQuestions.length,
            unanswered: _questions.length - _attendedQuestions.length,
            score: _totalScore,
          ),
        ),
      );
      return;
    }

    setState(() {
      _questionIndex++;
      _character = _currAns[_questionIndex];
      _startQuestionTimer(); // Start timer for the next question
    });

    // Ensure the PageController moves to the next page
    _pageController.animateToPage(
      _questionIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Prevent scrolling back to previous questions if the time has expired for them
  void _onPageChanged(int index) {
    if (_questionTimedOut[index]) {
      // Prevent moving back to a timed-out question
      _pageController.jumpToPage(_questionIndex);
    } else {
      setState(() {
        _questionIndex = index;
      });
      _startQuestionTimer(); // Start the timer for the new question
    }
  }

  // Show warning dialog before moving to the next question
  void _showWarningBeforeMovingNext() {
    if (!_answeredQuestions[_questionIndex]) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning'),
            content: Text(
                'You have not answered this question yet. Are you sure you want to skip it?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _nextQuestion(); // Skip to the next question
                },
                child: Text('Yes'),
              ),
            ],
          );
        },
      );
    } else {
      // If the user has answered the question, move to the next page
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Handle Done button click
  void _onDonePressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          totalQuestions: _questions.length,
          answered: _attendedQuestions.length,
          unanswered: _questions.length - _attendedQuestions.length,
          score: _totalScore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_questionIndex == 0) {
          return true; // Allow back navigation if it's the first question
        } else {
          setState(() {
            _questionIndex--;
            _character = _currAns[_questionIndex];
            if (_totalScore != 0 && _currScore[_questionIndex] == 1) {
              _totalScore--; // Deduct score if going back to a question with an incorrect answer
            }
          });
          return false; // Prevent the default back navigation
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text('Question ${_questionIndex + 1}'),
          backgroundColor: Colors.cyanAccent[400],
          actions: [
            IconButton(
              icon: Icon(Icons.check),
              onPressed: _onDonePressed, // Navigate to result page when done
            ),
          ],
        ),
        body: _questions.isEmpty
            ? Center(child: CircularProgressIndicator())
            : PageView.builder(
                controller: _pageController,
                itemCount: _questions.length,
                onPageChanged: _onPageChanged, // Handle page changes
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 15.0),
                      child: Column(
                        children: [
                          Text(
                            'Q${_questions[index]['questionNo']}: ${_questions[index]['questionText']}',
                            style: TextStyle(fontSize: 18),
                          ),
                          ...(_questions[index]['answers'] as List)
                              .map((answer) {
                            return ListTile(
                              title: Text(answer['text']),
                              leading: Radio<String>(
                                value: answer['text'],
                                groupValue: _character,
                                onChanged: (String? text) {
                                  setState(() {
                                    _character = text!;
                                    _currScore[index] = answer['score'];
                                    _currAns[index] = text;
                                    _answeredQuestions[index] = true;
                                    _attendedQuestions.add(index);
                                    _totalScore += answer['score'].toString() ==
                                            '1'
                                        ? 1
                                        : 0; // Update score when answer is selected
                                  });
                                },
                              ),
                            );
                          }).toList(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              'Time Remaining: $_remainingTime sec',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: CurvedNavigationBar(
          height: 60.0,
          backgroundColor: Colors.transparent,
          color: Colors.cyanAccent[400]!,
          animationDuration: Duration(milliseconds: 200),
          items: <Widget>[
            Text("Skip", style: TextStyle(color: Colors.black, fontSize: 20)),
            Icon(
              _questionIndex == _questions.length - 1
                  ? Icons.done
                  : Icons.navigate_next,
              size: 30,
              color: Colors.black,
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              // Show warning before skipping
              _skipQuestion();
            } else if (index == 1) {
              // Next or Done action
              _showWarningBeforeMovingNext(); // Show warning before moving to next
            }
          },
        ),
      ),
    );
  }
}
