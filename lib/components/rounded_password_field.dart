import 'package:flutter/material.dart';
import 'package:Chatify/components/text_field_container.dart';
import 'package:Chatify/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController passwordEditingController =
        new TextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: passwordEditingController,
        obscureText: true,
        validator: (pwValue) {
          if (pwValue.isEmpty) {
            return 'This field is mandatory';
          }
          if (pwValue.length < 6) {
            return 'Password must be at least 6 characters';
          }

          return null;
        },
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
