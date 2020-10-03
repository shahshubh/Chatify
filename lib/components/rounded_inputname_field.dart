import 'package:flutter/material.dart';
import 'package:Chatify/components/text_field_container.dart';
import 'package:Chatify/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  const RoundedInputField({
    Key key,
    this.hintText,
    this.icon = Icons.person,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController nameEditingController = new TextEditingController();
    return TextFieldContainer(
      child: TextFormField(
        controller: nameEditingController,
        validator: (val) {
          return val.isEmpty || val.length < 3
              ? "Enter Username 3+ characters"
              : null;
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
