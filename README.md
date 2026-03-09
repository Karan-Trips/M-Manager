# 💰 Money Manager (M-Manager)

**Money Manager** is a simple, intuitive, and feature-rich Flutter application designed to help you manage your personal finances effectively. Track your income, categorize your expenses effortlessly, and get personalized financial advice from an integrated AI chatbot.

## ✨ Features

- **Add Income**: Easily log all your sources of income to maintain a running balance.
- **Track Expenses**: Whenever you spend money, select the category that fits:
  - 🏥 Medical
  - 🍔 Food & Fast Food
  - 🏢 Office
  - 🏍️ Bike
  - 📦 Other
- **Financial Overview**: Get a clear breakdown of your expenses by category to understand where your money is going via the History & Summary screens.
- **🤖 AI Financial Advisor (New!)**: Integrated with Gemini AI.
  - Automatically analyzes your income and expenses.
  - Provides personalized suggestions on spending habits (where to cut back, where it's safe to spend).
  - Features an **Auto-Popup Advisor** that proactively greets you with insights on the Home Screen.
  - Alternatively, access detailed advice at any time via the Chatbot FAB or History screen.
- **User-friendly Interface**: Beautiful, intuitive design with smooth animations for quick and easy financial management.
- **Secure Authentication**: Uses Firebase Authentication for secure user login/signup.

## 🛠️ Tech Stack

This project is built using modern Flutter development practices:

- **Framework**: [Flutter](https://flutter.dev/)
- **Backend & Database**: [Firebase](https://firebase.google.com/) (Firestore, Authentication, Analytics, Crashlytics)
- **State Management**: [MobX](https://pub.dev/packages/mobx) & [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- **Routing & Navigation**: [GetX](https://pub.dev/packages/get)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it)
- **AI Integration**: Gemini AI using [dio](https://pub.dev/packages/dio) for HTTP requests
- **Environment Variables**: [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) for secure API key management

## 🚀 How to Run Locally

Follow these steps to get a copy of the project up and running on your local machine.

### Prerequisites

- Flutter SDK (>=3.2.3)
- Dart SDK
- Android Studio / Xcode (for emulation/compilation)
- A Firebase Project (for Authentication and Firestore)
- A [Google Gemini API Key](https://aistudio.google.com/app/apikey)

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Karan-Trips/M-Manager.git
   cd M-Manager
   ```

2. **Configure Environment Variables:**
   Create a `.env` file in the root directory of the project and add your Gemini API Key. Ensure there are no quotes or trailing spaces around the key.
   ```env
   # .env file content
   API_KEY=your_gemini_api_key_here
   ```

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Firebase Configuration:**
   Ensure your Firebase configuration files (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) are placed in their respective directories if not already configured via `flutterfire configure`.

5. **Run the App:**
   ```bash
   flutter run
   ```

## 📱 Screenshots

> *(Add screenshots of your application here. For example: Home Screen, Expense Logging, AI Chatbot Popup, History View)*

<p float="left">
  <!-- <img src="screenshots/home.png" width="30%" /> -->
  <!-- <img src="screenshots/chatbot.png" width="30%" /> -->
  <!-- <img src="screenshots/history.png" width="30%" /> -->
</p>

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit Pull Requests for any improvements or bug fixes.

## 📝 License

This project is open-source. Feel free to use and modify it as per your needs.

---
*Stay on top of your finances and make better decisions with **Money Manager**!*
