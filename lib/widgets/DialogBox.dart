import 'package:flutter/material.dart';

var primary = 0xFF03A9F4;
var secondary = 0xFF0277BD;

class DialogBox extends StatefulWidget {
  final String title, description, buttonText1, buttonText2;
  final Function button1Func, button2Func;
  final IconData icon;
  final Color iconColor;
  const DialogBox(
      {Key key,
        @required this.title,
        @required this.description,
        @required this.buttonText1,
        @required this.button1Func,
        this.buttonText2,
        this.button2Func,
        this.icon,
        this.iconColor})
      : super(key: key);
  @override
  _DialogBoxState createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: EdgeInsets.only(top: widget.icon == null ? 30.0 : 60),
                margin: EdgeInsets.only(top: widget.icon == null ? 0.0 : 60),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // To make the card compact
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          fontFamily: "Merriweather",
                          color: Color(secondary)
                      ),
                    ),
                    widget.description != ""
                        ? Column(
                      children: <Widget>[
                        SizedBox(height: 16.0),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0),
                            child: Text(
                              widget.description,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "NanumGothic",
                                  color: Color(primary)
                              ),
                            ))
                      ],
                    )
                        : Text(""),
                    widget.buttonText1 != ""
                        ? Column(
                      children: <Widget>[
                        SizedBox(height: 24.0),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: widget.buttonText2 != null
                                ? MainAxisAlignment.spaceEvenly
                                : MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: FlatButton(
                                  onPressed: widget.button1Func,
                                  child: Text(
                                    widget.buttonText1,
                                    style: TextStyle(
                                        color: widget.buttonText2 == null
                                            ? Color(primary)
                                            : Colors.grey[600]),
                                  ),
                                ),
                              ),
                              widget.buttonText2 != null
                                  ? Expanded(
                                child: FlatButton(
                                  onPressed: widget.button2Func,
                                  child: Text(
                                    widget.buttonText2,
                                    style: TextStyle(
                                        color: Color(primary)),
                                  ),
                                ),
                              )
                                  : Text("")
                            ],
                          ),
                        )
                      ],
                    )
                        : Text("")
                  ],
                ),
              ),
            ),
            widget.icon != null
                ? Positioned(
              left: 15,
              right: 15,
              child: CircleAvatar(
                backgroundColor: widget.iconColor != null
                    ? widget.iconColor
                    : Color(secondary),
                child: Icon(
                  widget.icon,
                  size: 60.0,
                ),
                radius: 60,
              ),
            )
                : Text("")
          ],
        ),
      ),
    );
  }
}

