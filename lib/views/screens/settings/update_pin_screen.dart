import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:ombor/models/helpers/password_helper.dart';
import 'package:ombor/utils/app_colors.dart';
import 'package:ombor/views/widgets/custom_button.dart';
import 'package:ombor/views/widgets/custom_text_field.dart';

class UpdatePinScreen extends StatefulWidget {
  const UpdatePinScreen({super.key});

  @override
  State<UpdatePinScreen> createState() => _UpdatePinScreenState();
}

class _UpdatePinScreenState extends State<UpdatePinScreen> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _repeatController = TextEditingController();

  String? _error;
  bool _isOldValid = true;
  bool _isNewValid = true;
  bool _isRepeatValid = true;

  Future<void> _updatePin() async {
    String oldPin = _oldController.text;
    String newPin = _newController.text;
    String repeatPin = _repeatController.text;

    bool validOld = await PasswordHelper.checkPassword(oldPin);

    if (!mounted) return;

    setState(() {
      _isOldValid = validOld;
      _isNewValid =
          newPin.length >= 4 && newPin.length <= 4; // PIN length check
      _isRepeatValid = newPin == repeatPin;
      _error = null;
    });

    if (!_isOldValid) {
      setState(() => _error = "old_pin_invalid".tr(context: context));
      return;
    }
    if (!_isNewValid) {
      setState(() => _error = "new_pin_invalid".tr(context: context));
      return;
    }
    if (!_isRepeatValid) {
      setState(() => _error = "pins_not_match".tr(context: context));
      return;
    }

    await PasswordHelper.setPassword(newPin);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("pin_updated_successfully".tr(context: context)),
        backgroundColor: AppColors.mainColor,
      ),
    );
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("update_pin_title".tr(context: context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "enter_old_and_new_pins".tr(context: context),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            CustomTextField(
              controller: _oldController,
              hintText: "old_pin".tr(context: context),
              icon: Icons.lock_outline,
              obscureText: true,
              keyboardType: TextInputType.number,
              isRequired: true,
              isValid: _isOldValid,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _newController,
              hintText: "new_pin".tr(context: context),
              icon: Icons.lock_reset,
              obscureText: true,
              keyboardType: TextInputType.number,
              isRequired: true,
              isValid: _isNewValid,
            ),
            const SizedBox(height: 20),

            CustomTextField(
              controller: _repeatController,
              hintText: "confirm_new_pin".tr(context: context),
              icon: Icons.lock_outline_rounded,
              obscureText: true,
              keyboardType: TextInputType.number,
              isRequired: true,
              isValid: _isRepeatValid,
            ),
            const SizedBox(height: 32),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomButton(
          color: AppColors.mainColor,
          onTap: _updatePin,
          child: Text(
            "update_pin_button".tr(context: context),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
