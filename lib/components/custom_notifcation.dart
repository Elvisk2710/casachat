import 'package:casachat/utils/colors.dart';
import 'package:flutter/material.dart';

class CustomNotification extends StatefulWidget {
  final String message;
  final bool error;
  final VoidCallback onDismiss;

  CustomNotification({
    required this.message,
    required this.onDismiss,
    required this.error,
  });

  @override
  _CustomNotificationState createState() => _CustomNotificationState();
}

class _CustomNotificationState extends State<CustomNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(_animationController);
    _animationController.forward();
    Future.delayed(Duration(seconds: 2), () {
      _animationController.reverse().then((_) {
        widget.onDismiss();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 60.0,
              ),
              margin: EdgeInsets.symmetric(vertical: 64, horizontal: 34),
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 800),
                child: Card(
                  color: widget.error == true
                      ? Colors.red
                      : accentColor,
                  elevation: 2,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.error == true
                              ? Icons.error
                              : Icons.check_circle,
                          color: widget.error == true
                              ? secondaryColor
                              : secondaryColor,
                          size: 24,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Container(
                          width: 250,
                          child: Text(
                            widget.message,
                            style: TextStyle(
                                color: secondaryColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void showCustomNotification(BuildContext context, String message, bool error) {
  OverlayEntry? _overlayEntry;

  if (_overlayEntry == null) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: CustomNotification(
          error: error,
          message: message,
          onDismiss: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
        ),
      ),
    );
    Overlay.of(context)!.insert(_overlayEntry!);
  }
}
