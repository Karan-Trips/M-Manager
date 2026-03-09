import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class ChatbotService {
  final Dio _dio = Dio();

  // Make sure your .env has API_KEY defined.
  // We'll use the Gemini Pro endpoint for textual generation.
  // Format: https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=YOUR_API_KEY
  Future<String> getSpendingAdvice({
    required double income,
    required double expenses,
    required String currency,
  }) async {
    final apiKey = dotenv.env['API_KEY']?.trim();
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey.contains('your_gemini_api_key_here')) {
      return "⚠️ API Key not found or invalid. Please configure your .env file with a valid Gemini API Key.";
    }

    final double balance = income - expenses;
    final String prompt = '''
You are a smart, professional financial advisor chatbot in a money management app.
Analyze the following user's monthly financial summary:
- Total Income: $currency $income
- Total Expenses: $currency $expenses
- Remaining Balance: $currency $balance

Provide a short, concise, and helpful suggestion (max 3-4 sentences) on their spending habits. 
Tell them if they are doing well, and where they should be careful about spending money. If they are overspending, give them strict advice.
''';

    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey";

    try {
      final response = await _dio.post(
        url,
        options: Options(headers: {'Content-Type': 'application/json'}),
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String text =
            data['candidates'][0]['content']['parts'][0]['text'];
        return text.trim();
      } else {
        return "Sorry, I couldn't get the advice right now. Please try again later.";
      }
    } catch (e) {
      debugPrint('ChatbotService Error: $e');
      if (e is DioException) {
        debugPrint('DioException response: ${e.response?.data}');
        return "Network error while connecting to the AI service: ${e.message}\nResponse: ${e.response?.data}";
      }
      return "An unexpected error occurred while fetching advice.";
    }
  }
}
