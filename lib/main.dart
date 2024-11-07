import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      home: SumCal(),
    );
  }
}

class SumCal extends StatefulWidget {
  const SumCal({super.key});

  @override
  State<SumCal> createState() => _SumCalState();
}

class _SumCalState extends State<SumCal> {
  final TextEditingController firstnoController = TextEditingController();
  final TextEditingController secondController = TextEditingController();

  List<String> _history = [];
  int _result = 0;
  String _quote = "Loading quote...";
  String _errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }
// fetch api url data
  Future<void> _fetchQuote() async {
    const String url = 'https://zenquotes.io/api/random';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _quote = "${jsonData[0]['q']} - ${jsonData[0]['a']}";
        });
      } else {
        _showError("Failed to load quote");
      }
    } catch (e) {
      _showError("Error loading quote");
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  bool _validateInput(String input) {
    final isNotEmpty = input.isNotEmpty;
    final isNumeric = RegExp(r'^[0-9]+$').hasMatch(input);
    return isNotEmpty && isNumeric;
  }

  void _calculateSum() {
    String num1Text = firstnoController.text;
    String num2Text = secondController.text;

    if (!_validateInput(num1Text) || !_validateInput(num2Text)) {
      _showError("Please enter valid numbers in both fields.");
      return;
    }

    setState(() {
      _errorMessage = "";
      int num1 = int.parse(num1Text);
      int num2 = int.parse(num2Text);
      _result = num1 + num2;
      _history.add('$num1 + $num2 = $_result');
    });

    firstnoController.clear();
    secondController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text("Sum Calculator", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          backgroundColor: Colors.blueGrey,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Quote of the Day:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8),
              Text(
                _quote,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(height: 32),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: firstnoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "First number",
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "+",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 100,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: secondController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Second number",
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: ElevatedButton(
                  onPressed: _calculateSum,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  child: Text(
                    'Calculate Sum',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Result: $_result',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_history[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
