import 'package:flutter/material.dart';
import 'package:Chatify/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Widget child;
  final Color color, textColor;
  const RoundedButton({
    Key key,
    this.child,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: FlatButton(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          color: color,
          onPressed: press,
          child: child,
          // child: Text(
          //   text,
          //   style: TextStyle(color: textColor),
          // ),
        ),
      ),
    );
  }
}
