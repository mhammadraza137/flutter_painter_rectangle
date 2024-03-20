import 'package:flutter/material.dart';
import 'package:painter_practice/models/draw_image.dart';
import 'package:painter_practice/models/draw_rectangle.dart';
import 'package:painter_practice/rectangle_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DrawRectangle> rectangles = [];
  List<DrawImage> images = [];
  int _rectangleIdCounter = 0;
  int? _selectedRectangleId;
  double _startX = 0;
  double _startY = 0;
  double _endX = 0;
  double _endY = 0;
  bool showIcon = false;
  bool _isRectangleSelected = false;
  double _imageX = 0;
  double _imageY = 0;
  double imageWidth = 0, imageHeight = 0;
  bool dragEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rectangle'),
        actions: !_isRectangleSelected ? [] : [
          IconButton(
              color: dragEnabled ? Colors.red : null,
              onPressed: () {
                setState(() {
                  dragEnabled = true;
                });
              },
              icon: const Icon(Icons.photo_size_select_large)),
          IconButton(
              color: !dragEnabled ? Colors.red : null,
              onPressed: () {
                setState(() {
                  dragEnabled = false;
                });
              },
              icon: const Icon(Icons.drag_handle)),
          IconButton(
              onPressed: () {
                setState(() {
                  rectangles.removeWhere(
                      (element) => element.id == _selectedRectangleId);
                  images.removeWhere(
                      (element) => element.id == _selectedRectangleId);
                  _selectedRectangleId = null;
                });
              },
              icon: const Icon(Icons.delete))
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (_isRectangleSelected) {
            DrawRectangle selectedRectangle = rectangles
                .firstWhere((element) => element.id == _selectedRectangleId);
            setState(() {
              _imageX = selectedRectangle.startX >= selectedRectangle.endX
                  ? selectedRectangle.endX
                  : selectedRectangle.startX;
              _imageY = selectedRectangle.startY >= selectedRectangle.endY
                  ? selectedRectangle.endY
                  : selectedRectangle.startY;

              imageHeight = selectedRectangle.endY > selectedRectangle.startY
                  ? selectedRectangle.endY - selectedRectangle.startY
                  : selectedRectangle.startY - selectedRectangle.endY;
              imageWidth = selectedRectangle.endX > selectedRectangle.startX
                  ? selectedRectangle.endX - selectedRectangle.startX
                  : selectedRectangle.startX - selectedRectangle.endX;
              for (var i = 0; i < rectangles.length; i++) {
                if (rectangles[i].id == _selectedRectangleId) {
                  rectangles[i] = DrawRectangle(
                    startX: dragEnabled
                        ? rectangles[i].startX
                        : rectangles[i].startX + details.delta.dx,
                    startY: dragEnabled
                        ? rectangles[i].startY
                        : rectangles[i].startY + details.delta.dy,
                    endX: rectangles[i].endX + details.delta.dx,
                    endY: rectangles[i].endY + details.delta.dy,
                    id: rectangles[i].id,
                  );
                  break;
                }
              }
              for (var i = 0; i < images.length; i++) {
                if (images[i].id == _selectedRectangleId) {
                  images[i] = DrawImage(
                    left: _imageX,
                    top: _imageY,
                    height: imageHeight,
                    width: imageWidth,
                    id: images[i].id,
                  );
                  break;
                }
              }
            });
          } else {
            setState(() {
              _endX = details.localPosition.dx;
              _endY = details.localPosition.dy;
            });
          }
        },
        onPanEnd: (details) {
          setState(() {
            if (_selectedRectangleId == null) {
              rectangles.add(DrawRectangle(
                startX: _startX,
                startY: _startY,
                endX: _endX,
                endY: _endY,
                id: _rectangleIdCounter++,
              ));
              _startX = 0;
              _startY = 0;
              _endX = 0;
              _endY = 0;
            }
          });
        },
        onPanStart: (details) {
          setState(() {
            _isRectangleSelected =
                _insideRect(details.localPosition.dx, details.localPosition.dy);
            if (!_isRectangleSelected) {
              dragEnabled = false;
              _startX = details.localPosition.dx;
              _startY = details.localPosition.dy;
            }
          });
        },
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: Stack(
            children: [
              Positioned.fill(
                  child: Container(
                    color: Colors.white,
                  )
              ),
              ...rectangles.map(
                (e) => CustomPaint(
                  painter: RectanglePainter(
                      startX: e.startX,
                      startY: e.startY,
                      endX: e.endX,
                      endY: e.endY,
                      color:
                          _selectedRectangleId == e.id ? Colors.green : null),
                ),
              ),
              if (_selectedRectangleId == null)
                CustomPaint(
                  painter: RectanglePainter(
                    startX: _startX,
                    startY: _startY,
                    endX: _endX,
                    endY: _endY,
                  ),
                ),
              ...images.map((e) {
                return Positioned(
                    left: e.left,
                    top: e.top,
                    child: Image.network(
                        height: e.height,
                        width: e.width,
                        "https://img.freepik.com/free-vector/hand-painted-watercolor-pastel-sky-background_23-2148902771.jpg",
                        fit: BoxFit.cover));
              }),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          if (_isRectangleSelected && !images.any((e) => e.id == _selectedRectangleId)) {
                            images.add(DrawImage(
                                id: _selectedRectangleId!,
                                left: _imageX,
                                top: _imageY,
                                width: imageWidth,
                                height: imageHeight));
                          }
                        });
                      },
                      child: const Text('Draw Image')))
            ],
          ),
        ),
      ),
    );
  }

  bool _insideRect(double x, double y) {
    bool isInside = false;
    for (var rectangle in rectangles) {
      if ((x >= rectangle.startX &&
              x <= rectangle.endX &&
              y >= rectangle.startY &&
              y <= rectangle.endY) ||
          (x <= rectangle.startX &&
              x >= rectangle.endX &&
              y <= rectangle.startY &&
              y >= rectangle.endY) ||
          (x >= rectangle.startX &&
              x <= rectangle.endX &&
              y <= rectangle.startY &&
              y >= rectangle.endY) ||
          (x <= rectangle.startX &&
              x >= rectangle.endX &&
              y >= rectangle.startY &&
              y <= rectangle.endY)) {
        _selectedRectangleId = rectangle.id;
        isInside = true;
        return isInside;
      } else {
        _selectedRectangleId = null;
        isInside = false;
      }
    }
    return isInside;
  }
}





