// import 'package:flutter/material.dart';

// import '../../generated/l10n.dart';

// class LanguageSelectionScreen extends StatefulWidget {
//   final Function(Locale) onLocaleChange;

//   const LanguageSelectionScreen({Key? key, required this.onLocaleChange}) : super(key: key);

//   @override
//   State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
// }

// class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(S.of(context).translate('select_language')),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//         elevation: 0,
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.deepPurple, Colors.purpleAccent],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               context.translate('select_language'),
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//             SizedBox(height: 30),
//             _buildLanguageButton(
//               context,
//               language: 'English',
//               locale: Locale('en'),
//               flag: '🇺🇸',
//             ),
//             SizedBox(height: 20),
//             _buildLanguageButton(
//               context,
//               language: 'हिन्दी',
//               locale: Locale('hi'),
//               flag: '🇮🇳',
//             ),
//             SizedBox(height: 40),
//             Text(
//               context.translate('greeting'),
//               style: TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLanguageButton(BuildContext context,
//       {required String language, required Locale locale, required String flag}) {
//     return ElevatedButton.icon(
//       onPressed: () => widget.onLocaleChange(locale),
//       icon: Text(
//         flag,
//         style: TextStyle(fontSize: 24),
//       ),
//       label: Text(
//         language,
//         style: TextStyle(fontSize: 20),
//       ),
//       style: ElevatedButton.styleFrom(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.deepPurple,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(30),
//         ),
//         elevation: 5,
//       ),
//     );
//   }
// }
