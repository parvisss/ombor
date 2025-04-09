import 'package:flutter/material.dart';
import 'package:ombor/models/helpers/password_helper.dart';
import 'package:pinput/pinput.dart';
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization

class PasswordScreen extends StatefulWidget {
  final VoidCallback onSuccess;

  const PasswordScreen({super.key, required this.onSuccess});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final int _pinLength = 4;

  String? _errorText;
  bool _isFirstTime = false;

  static const buttonColor = Color.fromARGB(255, 194, 223, 185);
  static const Color mainColor = Color(0xFF96C786);

  @override
  void initState() {
    super.initState();
    _checkPasswordExist();
  }

  Future<void> _checkPasswordExist() async {
    final storedPassword = await PasswordHelper.getPassword();
    setState(() {
      _isFirstTime = storedPassword == null;
    });
  }

  void _onKeyPressed(String value) {
    if (value == 'del') {
      if (_pinController.text.isNotEmpty) {
        setState(() {
          _pinController.text = _pinController.text.substring(
            0,
            _pinController.text.length - 1,
          );
          _errorText = null;
        });
      }
    } else if (_pinController.text.length < _pinLength) {
      setState(() {
        _pinController.text += value;
        _errorText = null;
      });

      if (_pinController.text.length == _pinLength) {
        _submit();
      }
    }
  }

  Future<void> _submit() async {
    String input = _pinController.text;
    if (input.length < _pinLength) {
      setState(() => _errorText = 'PIN not full'.tr()); // Use translated string
      return;
    }

    if (_isFirstTime) {
      await PasswordHelper.setPassword(input);
      widget.onSuccess();
    } else {
      bool correct = await PasswordHelper.checkPassword(input);
      if (correct) {
        widget.onSuccess();
      } else {
        setState(() {
          _errorText = 'Incorrect PIN'.tr(); // Use translated string
          _pinController.clear();
        });
      }
    }
  }

  Widget _buildNumberButton(String value) {
    IconData? icon;
    if (value == 'del') icon = Icons.backspace;
    if (value == 'ok') icon = Icons.check;

    return GestureDetector(
      onTap: () => value == 'ok' ? _submit() : _onKeyPressed(value),
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child:
              icon != null
                  ? Icon(icon, color: mainColor, size: 30)
                  : Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'del',
      '0',
      'ok',
    ];

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 60,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mainColor),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mainColor, width: 2),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isFirstTime
                          ? 'Enter a new PIN'
                              .tr() // Use translated string
                          : 'Enter PIN'.tr(), // Use translated string
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Pinput(
                      length: _pinLength,
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme: defaultPinTheme,
                      followingPinTheme: defaultPinTheme,
                      obscureText: true,
                      obscuringCharacter: '*',
                      showCursor: false,
                      readOnly: true,
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: GridView.count(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  children: buttons.map(_buildNumberButton).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
