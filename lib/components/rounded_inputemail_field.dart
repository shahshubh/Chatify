import 'package:flutter/material.dart';
import 'package:ChatApp/components/text_field_container.dart';
import 'package:ChatApp/constants.dart';

class RoundedInputEmailField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputEmailField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailEditingController = new TextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: emailEditingController,
        validator: (emailValue) {
          if (emailValue.isEmpty) {
            return 'This field is mandatory';
          }

          String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
              "\\@" +
              "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
              "(" +
              "\\." +
              "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
              ")+";
          RegExp regExp = new RegExp(p);

          if (regExp.hasMatch(emailValue)) {
            // So, the email is valid
            return null;
          }

          return 'This is not a valid email';
        },
        onChanged: onChanged,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
