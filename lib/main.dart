import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/weather_screen.dart';

// void main() {
//     runApp(const MyApp());
// }

Future<void> main() async {
    await dotenv.load(fileName: 'secrets.env'); // Load the .env file
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            // removes the debug banner from the top right corner of the screen
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark(), // with this, you can use dark mode for all the pages of the app
            
            home: const WeatherScreen(),            
        );
    }
}


