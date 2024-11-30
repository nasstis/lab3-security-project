import 'package:flutter/material.dart';
import 'package:password_project/ui/auth/slider_captcha/captcha_components.dart';

class SliderCaptcha extends StatefulWidget {
  const SliderCaptcha({
    required this.image,
    required this.onConfirm,
    this.title = 'Slide to authenticate',
    required this.colorBar,
    required this.colorCaptChar,
    super.key,
  });

  final Widget image;
  final Future<void> Function(bool value)? onConfirm;
  final String title;
  final Color colorBar;
  final Color colorCaptChar;

  @override
  State<SliderCaptcha> createState() => _SliderCaptchaState();
}

class _SliderCaptchaState extends State<SliderCaptcha>
    with SingleTickerProviderStateMixin {
  double heightSliderBar = 50;
  double _offsetMove = 0;
  double answerY = 0;
  bool isLock = false;
  SliderController controller = SliderController();
  SliderController unController = SliderController();
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SliderCaptCha(
              image: widget.image,
              offsetX: _offsetMove,
              offsetY: answerX,
              colorCaptChar: widget.colorCaptChar,
              sliderController: unController,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            height: heightSliderBar,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.colorBar,
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  offset: Offset(0, 0),
                  blurRadius: 2,
                  color: Colors.grey,
                )
              ],
            ),
            child: Stack(
              children: <Widget>[
                Center(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                  ),
                ),
                Positioned(
                  left: _offsetMove,
                  top: 0,
                  height: 50,
                  width: 50,
                  child: GestureDetector(
                    onHorizontalDragStart: (detail) =>
                        _onDragStart(context, detail),
                    onHorizontalDragUpdate: (DragUpdateDetails detail) {
                      _onDragUpdate(context, detail);
                    },
                    onHorizontalDragEnd: (DragEndDetails detail) {
                      checkAnswer();
                    },
                    child: Container(
                      height: heightSliderBar,
                      width: heightSliderBar,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onDragStart(BuildContext context, DragStartDetails start) {
    if (isLock) {
      return;
    }
    setState(() {
      RenderBox getBox = context.findRenderObject() as RenderBox;
      var local = getBox.globalToLocal(start.globalPosition);
      _offsetMove = local.dx - heightSliderBar / 2;
    });
  }

  _onDragUpdate(BuildContext context, DragUpdateDetails update) {
    if (isLock) {
      return;
    }
    RenderBox getBox = context.findRenderObject() as RenderBox;
    var local = getBox.globalToLocal(update.globalPosition);

    if (local.dx < 0) {
      setState(() {
        _offsetMove = 0;
      });
      return;
    }

    if (local.dx > getBox.size.width) {
      setState(() {
        _offsetMove = getBox.size.width - heightSliderBar;
      });
      return;
    }

    setState(() {
      _offsetMove = local.dx - heightSliderBar / 2;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = SliderController();

    controller.create = create;

    animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    animation = Tween<double>(begin: 1, end: 0).animate(animationController)
      ..addListener(() {
        setState(() {
          _offsetMove = _offsetMove * animation.value;
        });
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reset();
        }
      });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        controller.create.call();
      });
    });
    super.didChangeDependencies();
  }

  void onUpdate(double d) {
    setState(() {
      _offsetMove = d;
    });
  }

  Future<void> checkAnswer() async {
    if (isLock) {
      return;
    }
    isLock = true;

    if (_offsetMove < answerX + 10 && _offsetMove > answerX - 10) {
      await widget.onConfirm?.call(true);
    } else {
      await widget.onConfirm?.call(false);
    }
    isLock = false;
  }

  Offset? create() {
    animationController.forward().then((value) {
      setState(() {
        Offset? offset = unController.create.call();
        answerX = offset?.dx ?? 0;
        answerY = offset?.dy ?? 0;
      });
    });
    return null;
  }
}
