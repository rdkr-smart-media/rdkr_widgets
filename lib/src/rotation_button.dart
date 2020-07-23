import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotationButton extends StatefulWidget {
  final VoidCallback onTap;

  RotationButton({@required this.onTap});

  @override
  _RotationButtonState createState() => _RotationButtonState();
}

class _RotationButtonState extends State<RotationButton>
    with SingleTickerProviderStateMixin {
  final double rotationEnd = 320;
  RotationState state = RotationState.FRONT;
  double rotation = 0;
  Animation animation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: Duration(milliseconds: 500), vsync: this);
    animation = Tween<double>(begin: 0, end: rotationEnd).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    animationController.addListener(() {
      setState(() {
        rotation = animation.value;
      });
    });
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        if (state == RotationState.FRONT) {
          setState(() {
            state = RotationState.BACK;
          });
        } else if (state == RotationState.BACK) {
          setState(() {
            state = RotationState.FRONT;
          });
        } else if (state == RotationState.DRAGGING) {
          if (rotation == 0) {
            setState(() {
              state = RotationState.FRONT;
              widget.onTap();
            });
          } else if (rotation == rotationEnd) {
            setState(() {
              state = RotationState.BACK;
              widget.onTap();
            });
          }
        } else if (state == RotationState.REVERSING) {
          setState(() {
            if (rotation == 0) {
              setState(() {
                state = RotationState.FRONT;
              });
            } else if (rotation == rotationEnd) {
              setState(() {
                state = RotationState.BACK;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggle,
      onPanUpdate: (details) {
        setState(() {
          state = RotationState.DRAGGING;
          rotation -= details.delta.dx.toInt() * 2;
          if (rotation < 0) {
            rotation = 0;
          }
          if (rotation > rotationEnd) {
            rotation = rotationEnd;
          }
        });
      },
      onPanEnd: (details) {
        if (rotation > rotationEnd / 2) {
          animationController.forward(from: rotation / rotationEnd);
        } else {
          animationController.reverse(from: rotation / rotationEnd);
          setState(() {
            state = RotationState.REVERSING;
          });
        }
      },
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001) // perspective
          ..rotateX(250)
          ..rotateZ(0.01 * rotation), // changed
        alignment: FractionalOffset.center,
        child: Container(
          width: 150,
          height: 150,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: state == RotationState.FRONT
                ? Image(image: AssetImage("images/rotation_arrow.png"))
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Image(
                      image: AssetImage("images/rotation_arrow.png"),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  void toggle() {
    if (state == RotationState.FRONT) {
      animationController.forward();
    } else if (state == RotationState.BACK) {
      animationController.reverse();
    } else if (state == RotationState.DRAGGING) {
      if (rotation > rotationEnd / 2) {
        animationController.forward(from: rotation / rotationEnd);
      } else {
        animationController.reverse(from: rotation / rotationEnd);
      }
    }
    widget.onTap();
  }
}

enum RotationState {
  DRAGGING,
  REVERSING,
  FRONT,
  BACK,
}
