import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  final apiKey = "AIzaSyB0BBD3HimZ1Q2Nh7Y0dN3nE2upM8JlK0c";
  final url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=\$apiKey";

  final prompt = "test";

  try {
    final response = await dio.post(
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
    print(response.data);
  } on DioException catch (e) {
    print("Error: \${e.response?.statusCode}");
    print("Data: \${e.response?.data}");
  }
}
