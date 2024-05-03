import 'package:flutter/cupertino.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.dark,
      ),
      title: 'Calculator App',
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';
  List<String> _history = [];
  ScrollController _controller = ScrollController();

  void _onPressed(String buttonText) {
    setState(() {
      if (buttonText == 'AC') {
        _expression = '';
        _result = '';
        _history.clear();
      } else if (buttonText == '=') {
        try {
          Parser p = Parser();
          Expression exp = p.parse(_expression);
          ContextModel cm = ContextModel();
          double eval = exp.evaluate(EvaluationType.REAL, cm);
          _result =
              eval.toStringAsFixed(eval.truncateToDouble() == eval ? 0 : 2);

          // Push current expression to history stack
          _history.insert(0, _expression);
          if (_history.length > 2) {
            // Keep only two history entries
            _history.removeLast();
          }

          // Show result as current expression
          _expression = _result;
        } catch (e) {
          _result = 'Error';
        }
      } else if (buttonText == '⌫') {
        if (_expression.isNotEmpty) {
          // Remove the last character from the expression
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else {
        if (buttonText == '.') {
          // Check if there is already a decimal point in the current operand
          if (!_expression.endsWith('.') &&
              !(_expression.contains(RegExp(r'[.*/+-]')) &&
                  _expression
                      .substring(_expression.lastIndexOf(RegExp(r'[*/+-]')))
                      .contains('.'))) {
            _expression += buttonText;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
          }
        } else if (buttonText == '0') {
          // Remove leading zeros from numbers except when they are the only digit
          if (_expression.isEmpty ||
              RegExp(r'[1-9]').hasMatch(_expression) ||
              (_expression.startsWith('0.') &&
                  !_expression.substring(1).contains('.'))) {
            _expression += buttonText;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
          }
        } else if (buttonText == '(') {
          // Check if adding a left parenthesis is valid
          if (_expression.isEmpty ||
              _expression.endsWith('+') ||
              _expression.endsWith('-') ||
              _expression.endsWith('*') ||
              _expression.endsWith('/') ||
              _expression.endsWith('(')) {
            _expression += buttonText;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
          }
        } else if (buttonText == ')') {
          // Check if adding a right parenthesis is valid
          int leftParanthesisCount = _expression.split('(').length - 1;
          int rightParanthesisCount = _expression.split(')').length - 1;
          if (leftParanthesisCount > rightParanthesisCount &&
              _expression.isNotEmpty &&
              !_expression.endsWith('(') &&
              _expression != '.') {
            _expression += buttonText;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
          }
        } else if (buttonText == '+' ||
            buttonText == '-' ||
            buttonText == '*' ||
            buttonText == '/') {
          // Check if adding an operator is valid
          if (_expression.isNotEmpty &&
              !('+/*-'.contains(_expression[_expression.length - 1]))) {
            // If the last character is not an operator, add the new operator
            _expression += buttonText;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _controller.animateTo(_controller.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            });
          }
        } else {
          _expression += buttonText;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.animateTo(_controller.position.maxScrollExtent,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut);
          });
        }
      }
    });
  }

  Widget _buildButton(String buttonText,
      {Color color = CupertinoColors.systemGrey2}) {
    bool isArithmeticOperator = ['+', '-', '*', '/'].contains(buttonText);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(25.0), // Adjust the radius as needed
          child: CupertinoButton(
            onPressed: () =>
                _onPressed(isArithmeticOperator ? ' $buttonText ' : buttonText),
            color: color,
            padding: const EdgeInsets.all(18.0),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 26,
                color: CupertinoColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // const SizedBox(height: 16),
                  for (var i = 0; i < _history.length; i++)
                    Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          _history[i],
                          style: TextStyle(
                            fontSize: 25 + (i * 20), // Adjust font size
                            fontWeight: FontWeight.w400,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.only(right: 5.0, left: 5),
                    child: SingleChildScrollView(
                      controller: _controller,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _expression.isNotEmpty ? _expression : '0',
                        style: const TextStyle(
                          fontSize: 70,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('sin'),
              _buildButton('cos'),
              _buildButton('tan'),
              _buildButton('^'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('sqrt'),
              _buildButton('exp'),
              _buildButton('ln'),
              _buildButton('e'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('7'),
              _buildButton('8'),
              _buildButton('9'),
              _buildButton('/', color: const Color.fromARGB(226, 255, 204, 0)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('4'),
              _buildButton('5'),
              _buildButton('6'),
              _buildButton('*', color: const Color.fromARGB(226, 255, 204, 0)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('1'),
              _buildButton('2'),
              _buildButton('3'),
              _buildButton('-', color: const Color.fromARGB(226, 255, 204, 0)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('('),
              _buildButton('0'),
              _buildButton(')'),
              _buildButton('+', color: const Color.fromARGB(226, 255, 204, 0)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildButton('AC', color: CupertinoColors.systemGrey5),
              _buildButton('⌫'),
              _buildButton('.'),
              _buildButton('=', color: const Color.fromARGB(226, 255, 204, 0)),
            ],
          ),
        ],
      ),
    );
  }
}
