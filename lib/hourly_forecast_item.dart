// using separate class so that if we change 1 thing, all of the cards get the change
import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {                                                                                                                                                                                                                               
    final String time;
    final String temperature;
    final IconData icon;

    const HourlyForecastItem({
        super.key,
        required this.time,
        required this.temperature,
        required this.icon
    });

    @override
    Widget build(BuildContext context) {
        return Card(
            elevation: 10,
            color: const Color.fromARGB(255, 44, 41, 50), // changing the background color

            child: Container(
                width: 100,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                ),
                
                child: Column(
                    children: [
                        Text(
                            time,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1, // this will keep the text in 1 line but the unfit texts will be hidden, that's why we need 'overflow'
                            overflow: TextOverflow.ellipsis, // this is show ... just to let us know that there are moer texts
                        ),
                        
                        const SizedBox(height: 8),
                        Icon(icon, size: 32),
                        const SizedBox(height: 8),
                        Text(temperature),
                    ],
                ),
            ),
        );
    }
}

