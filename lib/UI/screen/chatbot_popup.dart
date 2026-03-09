import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:m_manager/ui/screen/chatbot_sheet.dart';

class ChatbotPopup {
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context,
      {required double income, required double expenses}) {
    if (_overlayEntry != null) return; // Prevent multiple popups

    _overlayEntry = OverlayEntry(
      builder: (context) => _ChatbotPopupWidget(
        income: income,
        expenses: expenses,
        onDismiss: hide,
        onTap: () {
          hide();
          ChatbotSheet.show(context, income: income, expenses: expenses);
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ChatbotPopupWidget extends StatefulWidget {
  final double income;
  final double expenses;
  final VoidCallback onDismiss;
  final VoidCallback onTap;

  const _ChatbotPopupWidget({
    required this.income,
    required this.expenses,
    required this.onDismiss,
    required this.onTap,
  });

  @override
  State<_ChatbotPopupWidget> createState() => _ChatbotPopupWidgetState();
}

class _ChatbotPopupWidgetState extends State<_ChatbotPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5), // Start above screen
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Auto-dismiss after 6 seconds if ignored
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        _close();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60.h, // Just below the safe area / app bar
      left: 16.w,
      right: 16.w,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Dismissible(
                key: const Key("chatbot_popup"),
                direction: DismissDirection.up,
                onDismissed: (_) => widget.onDismiss(),
                child: GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6A5AE0).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.smart_toy_rounded,
                              color: Color(0xFF6A5AE0),
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hi! I'm your AI Advisor. 👋",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "I've analyzed your recent spending. Tap me for tailored advice!",
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
