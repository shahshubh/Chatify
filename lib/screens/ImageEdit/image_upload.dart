import 'dart:async';
import 'dart:io';

import 'package:Chatify/constants.dart';
import 'package:Chatify/screens/ImageEdit/blocs/CanvasBloc/canvas_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/ColorBloc/colour_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/DrawingBloc/drawing_bloc.dart';
import 'package:Chatify/screens/ImageEdit/blocs/TextBloc/text_bloc.dart' as txt;
import 'package:Chatify/screens/ImageEdit/blocs/imageEdit/imageedit_bloc.dart';
import 'package:Chatify/models/models.dart';
import 'package:Chatify/models/text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:ui' as ui;

class Point {
  Offset offset;
  Color color;

  Point({this.offset, this.color});
}

class ImageEdit extends StatefulWidget {
  ImageEdit({Key key}) : super(key: key);

  @override
  _ImageEditState createState() => _ImageEditState();
}

class _ImageEditState extends State<ImageEdit> {

  Matrix4 matrix = Matrix4.identity();
  ScreenshotController _screenshotController = ScreenshotController();


  @override
  Widget build(BuildContext context) {

    // return TestTextView();
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<ImageeditBloc, ImageeditState>(
          builder: (context, state) {
            // return TextsAdded();
            
            if(state is ImageLoaded){
      // return AddText();
      return Stack(
        children: <Widget>[
          Screenshot(
            controller: _screenshotController,
                      child: Stack(
              children: <Widget>[
                Stack(children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(image: FileImage(state.file))
              ),
            ),
            BlocBuilder<DrawingBloc, DrawingState>(
              builder: (context, state) {
                if(state is LineDrawing){
                  return TextsAdded();
                }
                else{
                  return ImageCanvas();
                }
              },
            ),
         BlocBuilder<DrawingBloc, DrawingState>(
              builder: (context, state) {
                if(state is LineDrawing){
                  return ImageCanvas();
                }
                else {
                  return TextsAdded();
                }
              },
            )
            ],),
              ]
            ),
          ),
          BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              if(state is AddingText){
                return AddText();
              }
              return Container();
            },
          ),
          // Positioned(
          //   top: 100.0,
          //   child: SizedBox(
          //     width: MediaQuery.of(context).size.width,
          //     child: TextField(autofocus: true,)),
          // ),
              BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              if(state is TextDragged){
                  return Positioned(
                    top: 30,
                    child: TextDeleteBin(color: state.binColor,) ,
                  );
              }
              return Container();
            },
          ),
          Positioned(
            top: 30.0,
            right:30.0,
            child: BlocBuilder<DrawingBloc, DrawingState>(
              builder: (context, state) {
                if(state is TextDragged){
                  return SizedBox();                      }
                if(state is LineDrawing){
                  return CanvasActionButtons();
                }
                else if(state is AddingText){
                  return TextActionButtons();
                }
                if(state is DrawingInitial) return ActionButtons();
                
              },
            ),
          ),
      
          BlocBuilder<DrawingBloc, DrawingState>(
            builder: (context, state) {
              if((state is LineDrawing)){
                return Positioned(
                  bottom: 30.0,
                  child: ColorPallete(),
                );
              }
              else{
                return Container();
              }
            },
          ),
        ],
      );
            }
            return ImageCanvas();
          },

        ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF6F35A5),
        child: Icon(Icons.navigate_next),
        onPressed: () async {
            File image = await _screenshotController.capture();
            Navigator.pop(context,image);
        },
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}

class ImageCanvas extends StatelessWidget {
  const ImageCanvas({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, state) {
        print("drawng lines");
        var points = BlocProvider.of<CanvasBloc>(context).points;
        return FittedBox(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GestureDetector(
                      onPanStart: (details) {
                        BlocProvider.of<CanvasBloc>(context)
                              .add(PanUpdate(point: details.localPosition));
                      },
                      onPanUpdate: (details) =>
                          BlocProvider.of<CanvasBloc>(context)
                              .add(PanUpdate(point: details.localPosition)),
                      onPanEnd: (details) =>
                          BlocProvider.of<CanvasBloc>(context).add(PanEnd()),
                      child: CustomPaint(
                        painter: MyPainter(lines: points),
                      ))),
        );   
      },
    );
  }
}

class ImageUpload extends StatefulWidget {
  ImageUpload({Key key}) : super(key: key);

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  ImagePicker picker = ImagePicker();
  ui.Image image;

  List<Point> lines = new List<Point>();
  Color _color = Colors.pink;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FittedBox(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            excludeFromSemantics: true,
            onPanStart: (value) {
              print("onPanStart");
              setState(() {
                lines.add(Point(offset: value.localPosition, color: _color));
              });
            },
            onPanUpdate: (value) {
              print("OnPanUpdate : ${value.localPosition}");
              if (!lines.contains(value.localPosition)) {
                setState(() {
                  lines.add(Point(offset: value.localPosition, color: _color));
                });
              } else {
                print("not updated");
              }
            },
            onPanEnd: (value) {
              setState(() {
                lines.add(null);
              });
            },
            child: CustomPaint(
              painter: MyPainter(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  // ui.Image image;
  List<Pointer> lines;

  MyPainter({this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawImage(this.image, Offset.zero, Paint());
    var color = Colors.pink.withOpacity(1.0);
    final Paint circlePaint = Paint()
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < lines.length - 1; i++) {
      if (lines[i] != null && lines[i + 1] != null) {
        circlePaint.color = lines[i].color;
        canvas.drawLine(lines[i].offset, lines[i + 1].offset, circlePaint);
      } else if (lines[i] != null && lines[i + 1] == null) {
        circlePaint.color = lines[i].color;
        canvas.drawPoints(ui.PointMode.points, [lines[i].offset], circlePaint);
      }
    }

  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(MyPainter oldDelegate) => false;
}

class ColorRow extends StatelessWidget {
  final List<Color> colors;
  final Color selectedColor;

  const ColorRow({Key key, this.colors, this.selectedColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: colors.map((color) {
        return GestureDetector(
            onTap: () => BlocProvider.of<ColourBloc>(context)
                .add(ColourChange(color: color)),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white)),
              child: selectedColor == color
                  ? Center(
                      child: Container(
                        height: 5,
                        width: 5,
                        decoration: BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                      ),
                    )
                  : Container(),
            ));
      }).toList(),
    );
  }
}

class ColorPallete extends StatefulWidget {
  ColorPallete({Key key}) : super(key: key);

  @override
  _ColorPalleteState createState() => _ColorPalleteState();
}

class _ColorPalleteState extends State<ColorPallete> {
  PageController _controller;
  StreamController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = PageController();
    pageController = StreamController();

  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ColourBloc, ColourState>(
      condition: (_,__) => true,
      builder: (context, state) {

        Color selectedColor = (state as ColourInitial).color;
        return Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 40.0,
              child: PageView(
                dragStartBehavior: DragStartBehavior.start,
                controller: _controller,
                onPageChanged: (newPage) => pageController.sink.add(newPage),
                children: <Widget>[
                  ColorRow(
                    colors: [Colors.pink, Colors.grey, Colors.indigo],
                    selectedColor: selectedColor,
                  ),
                  ColorRow(
                    colors: [Colors.lightGreenAccent, Colors.red, Colors.black],
                    selectedColor: selectedColor,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            StreamBuilder(
              stream: pageController.stream,
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return PageIndicator(
                  totalPage: 2,
                  selectedPage: snapshot.data,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    pageController.close();
    super.dispose();
  }
}

class PageIndicator extends StatelessWidget {
  final int totalPage;
  final int selectedPage;
  const PageIndicator({Key key, this.totalPage, this.selectedPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalPage, (index) {
        return Padding(
          padding: EdgeInsets.only(left: 3.0, right: 3.0),
          child: index == selectedPage
              ? CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 5.0,
                )
              : CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 2.0,
                ),
        );
      }),
    );
  }
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({Key key}) : super(key: key);


  void addOverlay(BuildContext context) {

      OverlayState overlayState = Overlay.of(context);
      OverlayEntry overlayEntry;
      overlayEntry= OverlayEntry(
        builder: (context) => AddText()        
      );

      overlayState.insert(overlayEntry);  
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.text_format,color: kPrimaryColor,size: 30.0,),
            onPressed: (){
              BlocProvider.of<DrawingBloc>(context).add(DrawText());
          },
          ),
          GestureDetector(
            // onTap: () => BlocProvider.of<CanvasBloc>(context).add(UndoChange()),
            onLongPress: () {
              HapticFeedback.vibrate();
              // BlocProvider.of<CanvasBloc>(context).add(ClearCanvas());
            },
            onTap: () {
              BlocProvider.of<DrawingBloc>(context).add(DrawLine());
            },
            child: Icon(
              Icons.linear_scale,
              color: kPrimaryColor,
              size: 30.0,
            ),
          )
        ],
      ),
    );
  }
}



class AddText extends StatefulWidget {
  AddText({Key key}) : super(key: key);

  @override
  _AddTextState createState() => _AddTextState();
}

class _AddTextState extends State<AddText> {

  TextEditingController _controller;
  FocusNode focus;
  final _textKey = GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = TextEditingController()..value = TextEditingValue(text: '');
    focus = FocusNode();
    final _state = BlocProvider.of<txt.TextBloc>(context).state as txt.AddingText;
    color = _state.color;
    fontFamily = _state.fontFamily;
    textStyle = TextStyle(color: color,fontFamily: fontFamily,fontSize: 30.0);
    if(_state.initalText != null) _controller.value = TextEditingValue(text: _state.initalText);
     _controller.addListener(() {
            print(_controller.text) ;
            BlocProvider.of<txt.TextBloc>(context).add(txt.TextChanged(text: _controller.text,textStyle: textStyle));
    });
  }

  Color color;
  String fontFamily ;
  TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    print("builed");
    // _controller.clear();
    return BlocConsumer<txt.TextBloc, txt.TextState>(
      listener: (context,state){
        if(state is txt.AddingText){
          color = state.color;
          fontFamily = state.fontFamily;
          textStyle = TextStyle(color: color,fontFamily: fontFamily,fontSize: 30.0);
          BlocProvider.of<txt.TextBloc>(context).add(txt.TextChanged(text: _controller.text,textStyle: textStyle));

        }
      },
      builder: (context, state) {
        if(state is txt.AddingText) {
          return Scaffold(
            backgroundColor: Colors.black54,
            body: SafeArea(
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Center(
            child: SizedBox(
              height: 100.0,
              width: MediaQuery.of(context).size.width,
              child: TextField( 
                  key: _textKey,
                   controller: _controller,
                   textAlign: TextAlign.center, 
                   decoration: InputDecoration(border: InputBorder.none),
                   //  decoration: InputDecoration(border: InputBorder.none,filled: false),
                    style: textStyle ,
                    autofocus: true,
                  ),
            ),
          ),
          Positioned(
            bottom: 30.0,
            child: ColorPallete(),
          )
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }


  @override
  void dispose() { 
    _controller.dispose();
    super.dispose();
  }
}


class TextsAdded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<txt.TextBloc, txt.TextState>(
      builder: (context, state) {
        var count = -1;
          var texts = BlocProvider.of<txt.TextBloc>(context).texts;
          // return TextView(text: state.texts[0],index: 0);
        if(texts.length > 0) {
          print("Text length : ${texts.length}");
            return Stack(
                  children: texts.map((e) {
                    count ++;
                    return TextView(text: e,index: count,);
                  }).toList()
              );

        }
        else{
            return Container();
        }
      },
    );
  }
}




class TextPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    ui.ParagraphStyle paragraphStyle =
        ui.ParagraphStyle(textDirection: TextDirection.ltr);
    ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
    ui.TextStyle textStyle = ui.TextStyle(
        fontSize: 20.0, color: Colors.deepPurple, fontFamily: 'Lato');
    paragraphBuilder.pushStyle(textStyle);
    paragraphBuilder.addText('Hello');
    ui.TextStyle textStyle1 =
        ui.TextStyle(fontSize: 20.0, color: Colors.pink, fontFamily: 'Lato');
    paragraphBuilder.pushStyle(textStyle1);
    paragraphBuilder.addText('World');
    paragraphBuilder.pop();

    final ui.Paragraph paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 300.0));

    // canvas.drawParagraph(paragraph, Offset(size.height / 2, size.width / 2));
  }

  @override
  bool shouldRepaint(TextPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(TextPainter oldDelegate) => false;
}


class CanvasActionButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.replay,color: kPrimaryColor,),
          onPressed: (){
            BlocProvider.of<CanvasBloc>(context).add(UndoChange());
          },
        ),
        IconButton(
          icon: Icon(Icons.done,color: kPrimaryColor,),
          onPressed: (){
            BlocProvider.of<DrawingBloc>(context).add(LineDrawn());
          },
        )
      ],
    );
  }
}


class TextActionButtons extends StatefulWidget {
  @override
  _TextActionButtonsState createState() => _TextActionButtonsState();
}

class _TextActionButtonsState extends State<TextActionButtons> with TickerProviderStateMixin {

  List<Map> fonts ;
  int _fontSelected;
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() { 
    super.initState();
    fonts = BlocProvider.of<txt.TextBloc>(context).fonts;
    _fontSelected = 0;
    _controller = AnimationController(duration: Duration(milliseconds: 250),vsync: this);
    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed){
        _controller.reverse();
      }
    });
    _animation = CurvedAnimation(curve: Curves.bounceOut,parent: Tween<double>(begin: 1.0,end: 0.8).animate(_controller));

  }




  @override
  Widget build(BuildContext context) {    
    return Row(
      children: <Widget>[
        AnimatedBuilder(
          animation: _animation,
          child: FlatButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
            side: BorderSide(color: Colors.white)
          ),
          child: Text((fonts[_fontSelected]['title']).toString().toUpperCase(),style: TextStyle(color: Colors.white),),
          onPressed: (){
            _controller.forward();
             var _newFont = _fontSelected == 2 ? 0 : ++_fontSelected;
            BlocProvider.of<txt.TextBloc>(context).add(txt.ChangeTextFont(index: _newFont));
            setState(() {
              _fontSelected = _newFont;
            });
          },
        ),
          builder: (BuildContext context, Widget child) {
            return  Transform(
              transform: Matrix4.identity()..scale(_animation.value),
              child: child,
            );
          },
        ),
        SizedBox(
            width: 50.0,
        ),
        IconButton(
          icon: Icon(Icons.done,color: Colors.white,),
          onPressed: (){
            BlocProvider.of<DrawingBloc>(context).add(TextInserted());
            BlocProvider.of<txt.TextBloc>(context).add(txt.AddText());
          },
        )
      ],
    );
  }
}


class TextView extends StatefulWidget {
  TextView({Key key,this.text,this.index}) : super(key: key);
  final TextModel text;
  final int index;

  @override
  _TextViewState createState() => _TextViewState();
}

class _TextViewState extends State<TextView> {

  double xPos;
  double yPos;
  double _scale;
  double _baseScale;
  Offset _basePosition;
  Offset orignalOffset;
  double _angle;
  double _baseAngle;
  bool _dragState ;
  bool _onDelete;
  @override
  void initState() { 
    super.initState();
    xPos = widget.text.position.dx;
    yPos = widget.text.position.dy;
    _angle = widget.text.rotation;
    _scale = widget.text.scale;
    orignalOffset = widget.text.position;
    _baseScale = _scale;
    _baseAngle = _angle;
    _dragState = false;
    _onDelete = false;
    // _angle = 0.0;
  }
  @override
  Widget build(BuildContext context) {


    return Positioned(
      top: yPos,
      left: xPos,
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()..scale(_scale)..rotateZ(_angle),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            BlocProvider.of<txt.TextBloc>(context).add(txt.EditText(index:widget.index));
          },
          onScaleStart: (details){
            _basePosition = details.focalPoint;
          },
          onScaleUpdate: (details){
            if(!_dragState){
              BlocProvider.of<DrawingBloc>(context).add(TextDraggingStart());
              _dragState = true;
            }
            print("Global offset:${details.focalPoint}");
            if((details.focalPoint.dx <=90) && (details.focalPoint.dy <= 90)){
                if(!_onDelete){
                  BlocProvider.of<DrawingBloc>(context).add(TextDragginOnBin());
                    _onDelete = true;
                }
            }
            else {
              if(_onDelete){
                BlocProvider.of<DrawingBloc>(context).add(TextDraggingStart());
                _onDelete = false;
              }
            }
            var newOffset = details.focalPoint - _basePosition;
            print(newOffset);
            double xDiff = newOffset.dx;
            double yDiff = newOffset.dy;
            print(details.scale);
            print("Rotation : ${details.rotation}");
            setState(() {
                xPos = orignalOffset.dx + xDiff;
                yPos = orignalOffset.dy + yDiff;
                _scale = _baseScale + (details.scale - 1.0);
                _angle = _baseAngle + details.rotation;
            });
            BlocProvider.of<txt.TextBloc>(context).add(txt.OnScaleChanged(index: widget.index,position:Offset(xPos,yPos),rotation: _angle,scale: _scale ));
          },
          onScaleEnd: (details){
              _baseScale = _scale;
              orignalOffset = Offset(xPos,yPos);
              _baseAngle = _angle;
              _dragState = false;
              BlocProvider.of<DrawingBloc>(context).add(TextDraggingEnd());
              if((orignalOffset.dx <=90) && (orignalOffset.dy <= 90)){
              BlocProvider.of<txt.TextBloc>(context).add(txt.DeleteText(index: widget.index));
          }
          },
          child: Container(
            child: Text(widget.text.text,style: widget.text.textStyle,),
          ),
        ),
      ),
    );
  }
}



class TestTextView extends StatefulWidget {
  TestTextView({Key key}) : super(key: key);

  @override
  _TestTextViewState createState() => _TestTextViewState();
}

class _TestTextViewState extends State<TestTextView> {

  double xPos = 100;
  double yPos = 200;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            top: yPos,
            left: xPos,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (details){
                // setState(() {
                // xPos = details.localPosition.dx;
                // yPos = details.localPosition.dy;
                // });
              },
              onPanUpdate: (details){
                print(details.localPosition);
                setState(() {
                xPos += details.delta.dx;
                yPos += details.delta.dy;
                });              },
              child: Container(
                color: Colors.red,
                height: 200.0,
                width: 200,
                child: Text(
                  "Hello World"
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TextDeleteBin extends StatefulWidget {
  TextDeleteBin({Key key,this.color}) : super(key: key);

  Color color;

  @override
  _TextDeleteBinState createState() => _TextDeleteBinState();
}

class _TextDeleteBinState extends State<TextDeleteBin> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(60.0)
        )
      ),
      duration: Duration(milliseconds: 200),
      alignment: Alignment.topLeft,
      padding: EdgeInsets.all(7.0),
      child: Icon(
        MdiIcons.trashCanOutline,
        color: Colors.white,
      ),
    );
  }
}