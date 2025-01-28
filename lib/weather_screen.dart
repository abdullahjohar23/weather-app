import 'dart:ui';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
    const WeatherScreen({super.key});

    @override
    State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
    // it's better to put the generic type for the Future
    // if you look at the json, it is a Map & its keys are Strings and values are multiple type (dynamic)
    late Future<Map<String, dynamic>> weatherRefresh;
    late String theCity;
    
    Future<Map<String, dynamic>> getCurrentWeather() async {
        try {
            String cityName = 'Chittagong';
            theCity = cityName;
            String apiKey = dotenv.env['API_KEY'] ?? 'API key not found';
            
            final res = await http.get(
                Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,&APPID=$apiKey'),

                // we don't wanna show our API key. To do that, we can store the API key in a separate file (.env) and put it in gitignore
                // URI = Uniform Resource Identifier, ULR = Uniform Resource Locator [URL is a subtype of URI]
            );

            final data = jsonDecode(res.body);

            if (data['cod'] != '200') {
                throw 'An unexpected error occurred!!!!!';
            }

            return data;
        } catch (e) {
            throw e.toString();
        }
    }

    @override
    void initState() {
        super.initState();
        weatherRefresh = getCurrentWeather();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text(
                    'Weather App',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                    ),
                ),
                
                centerTitle: true,
                
                actions: [
                    IconButton(
                        onPressed: () {
                            setState(() {
                                weatherRefresh = getCurrentWeather();
                            });
                        },

                        icon: const Icon(Icons.refresh) // you can also work with GestureDetector() or InkWell()
                    ),
                ],
            ),

            // there is also LinearProgressIndicator, RefreshProgressIndicator
            // we're checking 0, because 0K is freezing death temperature
            // if you're in C or F, put an impossible scale
            // keep it in center for better view
            // .adaptive helps to adapt the OS type (it gives different refresh type for IOS)

            body: FutureBuilder(
                // FutureBuilder listens to a Future, waits for it to complete, and rebuilds the UI based on its state (loading, success, or error)
                future: weatherRefresh,
                
                builder: (context, snapshot) {
                    // print(snapshot); // Snapshot in FutureBuilder represents the current state of the Future (like loading, success, or error) and holds its data or error if available

                    // in previous code, we saw 'snapshot' prints 'ConnectionState'
                    // for waiting, we will use the loading now
                    // so we don't need to use isLoading
                    if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                    }

                    // so we don't need to check the value of isLoading in every exception
                    if (snapshot.hasError) {
                        return Center(child: Text(snapshot.error.toString()));
                    }

                    final theData = snapshot.data!;

                    final currentWeatherData = theData['list'][0];

                    // for main temperature section
                    // need to convert it to celsius
                    final currentTemp = (currentWeatherData['main']['temp']) - 273.15; // finalize the temperature in the display
                    final currentSky = currentWeatherData['weather'][0]['main']; // finalize the sky type in the display

                    // for additional section
                    final currentHumidity = (currentWeatherData['main']['humidity']);
                    final currentWindSpeed = currentWeatherData['wind']['speed'];
                    final currentPressure = currentWeatherData['main']['pressure'];

                    return Padding(
                        // to give padding to all three sections
                        padding: const EdgeInsets.all(16.0),
                        
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                // display temperature work ***************
                                SizedBox(
                                    width: double.infinity, // to get the whole screen width
                                    child: Card(
                                        elevation: 10,
                                        color: const Color.fromARGB(255, 44, 41, 50), // changing the background color

                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                        ),

                                        // display display temperature section
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(16), // apply this to visible the elevation or to remove the whole blurry bg

                                            child: BackdropFilter(
                                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                
                                                child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                        children: [
                                                            // the displayed temperature
                                                            Text(
                                                                '$theCity : ${currentTemp.toStringAsFixed(0)}° C', // display the real temperature
                                                                style: const TextStyle(
                                                                    fontSize: 28,
                                                                    fontWeight: FontWeight.bold,
                                                                ),
                                                            ),

                                                            const SizedBox(height: 16),

                                                            // fetched weather icon
                                                            Icon(
                                                                currentSky == 'Clouds' || currentSky == 'Rain'
                                                                ? Icons.cloud
                                                                : Icons.sunny,
                                                                size: 64,
                                                            ),

                                                            const SizedBox(height: 16),

                                                            // fetch weather type name
                                                            Text(
                                                                '$currentSky',
                                                                style: const TextStyle(
                                                                    fontSize: 22,
                                                                ),
                                                            )
                                                        ],
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ),
                                ),

                                const SizedBox(height: 20),

                                // hourly forecast work
                                const Text(
                                    'Hourly Forecast',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),

                                const SizedBox(height: 10),

                                // ListView.builder(): A Flutter widget that efficiently creates a scrollable list by building items lazily as they are scrolled into view

                                SizedBox(
                                    height: 120,
                                    child: ListView.builder(
                                        itemCount: 8,
                                        scrollDirection: Axis.horizontal, // to change the direction of the scroll, but still height issue because the time goes to next line; let's keep it in 1 line
                                        
                                        itemBuilder: (context, index) {
                                            final hourlyForecast = theData['list'][index + 1];
                                            final hourlyTemp = (hourlyForecast['main']['temp'] - 273.15).toStringAsFixed(2);
                                            final hourlySky = theData['list'][index + 1]['weather'][0]['main'];
                                            final time = DateTime.parse(hourlyForecast['dt_txt'].toString());

                                            return HourlyForecastItem(
                                                time: DateFormat.j().format(time), // instead of "DateFormat.j()", you can use "DateFormat('j')"
                                                temperature: '$hourlyTemp° C',
                                                icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                                                ? Icons.cloud
                                                : Icons.sunny,
                                            );
                                        },
                                    ),
                                ),

                                const SizedBox(height: 20),

                                // additional information work
                                const Text(
                                    'Additional Information',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                    ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                        AdditionalInfoItem(
                                            icon: Icons.water_drop,
                                            label: 'Humidity',
                                            value: '${currentHumidity.toString()}%',
                                        ),
                                            
                                        AdditionalInfoItem(
                                            icon: Icons.air,
                                            label: 'Wind Speed',
                                            value: '${currentWindSpeed.toString()}m/s'
                                        ),
                                        
                                        AdditionalInfoItem(
                                            icon: Icons.beach_access,
                                            label: 'Pressure',
                                            value: '${currentPressure.toString()} hPa',
                                        ),
                                    ],
                                ),
                            ],
                        ),
                    );
                },
            ),
        );
    }
}
