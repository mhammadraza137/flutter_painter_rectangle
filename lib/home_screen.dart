import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Rectangle> rectangles = [];
  int _rectangleIdCounter = 0;
  int? _selectedRectangleId;
  double _startX = 0;
  double _startY = 0;
  double _endX = 0;
  double _endY = 0;
  bool showIcon = false;
  bool _dragging = false;
  double _imageX = 0;
  double _imageY = 0;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {


          // if (_dragging) {
          //   setState(() {
          //     _imageX += details.delta.dx;
          //     _imageY += details.delta.dy;
          //   });
          // }
          if (_selectedRectangleId != null) {
            setState(() {
              // Find the rectangle by ID and update its position
              for (var i = 0; i < rectangles.length; i++) {
                if (rectangles[i].id == _selectedRectangleId) {
                  rectangles[i] = Rectangle(
                    startX: rectangles[i].startX + details.delta.dx,
                    startY: rectangles[i].startY + details.delta.dy,
                    endX: rectangles[i].endX + details.delta.dx,
                    endY: rectangles[i].endY + details.delta.dy,
                    id: rectangles[i].id,
                  );
                  break;
                }
              }
            });
          }
          setState(() {
            _endX = details.localPosition.dx;
            _endY = details.localPosition.dy;
            print('endx : $_endX endy : $_endY');

          });
        },
        onPanEnd: (details) {
          setState(() {
            if(_selectedRectangleId == null){
              print('id is null');
              rectangles.add(Rectangle(
                startX: _startX,
                startY: _startY,
                endX: _endX,
                endY: _endY,
                id: _rectangleIdCounter++,
              ));
              print('rectangle id is :: $_rectangleIdCounter');
            }


          });
        },
        onPanStart: (details) {
          setState(() {
              _startX = details.localPosition.dx;
              _startY = details.localPosition.dy;
            print('starrtx : $_startX starty : $_startY');
              _dragging = _insideRect(details.localPosition.dx, details.localPosition.dy);
              print('dragging is :: $_dragging');
          });
        },

        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Stack(
            children: [
              Positioned.fill(child: Image.network("https://img.freepik.com/free-vector/hand-painted-watercolor-pastel-sky-background_23-2148902771.jpg", fit: BoxFit.cover,)),
              ...rectangles.map((e) => CustomPaint(
                painter: RectanglePainter(
                  startX: e.startX,
                  startY: e.startY,
                  endX: e.endX,
                  endY: e.endY,
                ),
              ),),
              if(_selectedRectangleId == null)CustomPaint(
                painter: RectanglePainter(
                  startX: _startX,
                  startY: _startY,
                  endX: _endX,
                  endY: _endY,
                ),
              ),
              if(showIcon)
                Positioned(
                    left: _imageX,
                    top: _imageY,
                    child: Image.network(height: _endY > _startY ? _endY-_startY :_startY-_endY, width: _endX > _startX ? _endX-_startX : _startX-_endX,"https://img.freepik.com/free-vector/hand-painted-watercolor-pastel-sky-background_23-2148902771.jpg", fit: BoxFit.cover)),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(onPressed: (){
                    setState(() {
                      showIcon =  !showIcon;
                    });
                  }, child: Text('show icon')))

            ],
          ),
        ),
      ),
    );
  }
  bool _insideRect(double x, double y) {
    for (var rectangle in rectangles) {
      print('hii');
      print(x >= rectangle.startX && x <= rectangle.endX);
      print(y >= rectangle.startY  );
      print('22 :${y <= rectangle.endY}');
      if (x >= rectangle.startX && x <= rectangle.endX &&
          y >= rectangle.startY && y <= rectangle.endY) {
        _selectedRectangleId = rectangle.id;
        return true;
      } else{
        _selectedRectangleId = null;
        return false;
      }
    }
    return false;
  }
  }

class RectanglePainter extends CustomPainter {
  final double startX;
  final double startY;
  final double endX;
  final double endY;

  RectanglePainter({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rect = Rect.fromPoints(
      Offset(startX, startY),
      Offset(endX, endY),
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Rectangle {
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final int id;

  Rectangle({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.id,
  });
}




