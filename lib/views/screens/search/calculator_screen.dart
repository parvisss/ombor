import 'package:flutter/material.dart';
import 'package:ombor/utils/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '';

  final List<String> buttons = [
    'C',
    '⌫',
    '(',
    ')',
    '7',
    '8',
    '9',
    '÷',
    '4',
    '5',
    '6',
    '×',
    '1',
    '2',
    '3',
    '-',
    '0',
    '.',
    '=',
    '+',
  ];

  void _numClick(String text) {
    setState(() {
      _expression += text;
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _result = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isNotEmpty) {
        _expression = _expression.substring(0, _expression.length - 1);
      }
    });
  }

  void _calculate() {
    try {
      String exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      final result = _evaluateExpression(exp);
      setState(() {
        _result = result.toString();
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  double _evaluateExpression(String exp) {
    // Eval uchun oddiy parser (basic)
    // Bu faqat oddiy hisob-kitoblar uchun
    final expWithOperators = exp.replaceAll('×', '*').replaceAll('÷', '/');
    return double.parse(
      (Function.apply(double.parse, [], {#expression: expWithOperators})
                  as double?)
              ?.toString() ??
          '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Kalkulyator"),
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: width,
              color: AppColors.backgroundSecondary,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(_expression, style: const TextStyle(fontSize: 24)),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                itemCount: buttons.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final text = buttons[index];

                  return GestureDetector(
                    onTap: () {
                      if (text == 'C') {
                        _clear();
                      } else if (text == '=') {
                        _calculate();
                      } else if (text == '⌫') {
                        _backspace();
                      } else {
                        _numClick(text);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getButtonColor(text),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(text),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor(String text) {
    if (text == 'C' || text == '⌫') return AppColors.negative.withOpacity(0.1);
    if (text == '=') return AppColors.buttonColor;
    if (['÷', '×', '-', '+', '(', ')'].contains(text)) {
      return AppColors.mainColor;
    }
    return AppColors.buttonColor;
  }

  Color _getTextColor(String text) {
    if (text == 'C' || text == '⌫') return AppColors.negative;
    if (text == '=') return AppColors.positive;
    if (['÷', '×', '-', '+', '(', ')'].contains(text)) {
      return AppColors.secondaryColor;
    }
    return AppColors.black;
  }
}
