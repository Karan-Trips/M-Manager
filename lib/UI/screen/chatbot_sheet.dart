import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:m_manager/services/chatbot_service.dart';

class ChatbotSheet extends StatefulWidget {
  final double income;
  final double expenses;

  const ChatbotSheet({
    super.key,
    required this.income,
    required this.expenses,
  });

  static void show(BuildContext context,
      {required double income, required double expenses}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatbotSheet(
        income: income,
        expenses: expenses,
      ),
    );
  }

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  final ChatbotService _chatbotService = ChatbotService();
  String _advice = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdvice();
  }

  Future<void> _fetchAdvice() async {
    setState(() {
      _isLoading = true;
      _advice = "";
    });
    print(widget.income);
    print(widget.expenses);

    final output = await _chatbotService.getSpendingAdvice(
      income: widget.income,
      expenses: widget.expenses,
      currency: "₹",
    );

    if (mounted) {
      setState(() {
        _advice = output;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _purple = const Color(0xFF6A5AE0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
              height: 5.h,
              width: 50.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _purple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.smart_toy_rounded, color: _purple, size: 24),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Financial Advisor",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Personalized spend insights",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: Colors.grey.shade600),
                )
              ],
            ),
          ),

          Divider(color: Colors.grey.shade200, height: 30.h),

          // Content Area
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              physics: const BouncingScrollPhysics(),
              child: _isLoading
                  ? _buildLoadingState(_purple)
                  : _buildAdviceState(_purple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color purple) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20.h),
        // A simple CircularProgressIndicator if lottie is not present,
        // but we'll try to use the existing loading.json if it's there
        SizedBox(
          height: 100.h,
          child: Lottie.asset(
            'images/loading.json',
            errorBuilder: (context, error, stackTrace) =>
                CircularProgressIndicator(color: purple),
          ),
        ),
        SizedBox(height: 20.h),
        Text(
          "Analyzing your finances...",
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 40.h), // padding
      ],
    );
  }

  Widget _buildAdviceState(Color purple) {
    // Determine the general tone based on balance
    final balance = widget.income - widget.expenses;
    final isGood = balance >= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: purple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: purple.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(
                isGood ? Icons.thumb_up_alt_rounded : Icons.warning_rounded,
                color: isGood ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  "Based on this month's activity: \nIncome: ₹${widget.income.toStringAsFixed(0)} • Expenses: ₹${widget.expenses.toStringAsFixed(0)}",
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          "My Advice:",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: purple,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: purple.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                )
              ]),
          child: Text(
            // Show markdown basic formatting if returned by Gemini
            _advice.replaceAll('**', ''),
            style: TextStyle(
              fontSize: 15.sp,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _fetchAdvice,
            icon: Icon(Icons.refresh_rounded, color: purple),
            label: Text("Refresh Advice",
                style: TextStyle(color: purple, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
                side: BorderSide(color: purple.withOpacity(0.3)),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r))),
          ),
        ),
        SizedBox(height: 40.h), // padding
      ],
    );
  }
}
