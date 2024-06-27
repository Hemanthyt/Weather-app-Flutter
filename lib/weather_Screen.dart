// ignore_for_file: file_names, avoid_print, non_constant_identifier_names

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'Additional_info_item.dart';
import 'hourly_Forecast_item.dart';

import 'package:http/http.dart' as http;
import 'apisecretkeys.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather = getCurrentWeather();

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String CityName = 'London';
      final res = await http.get(Uri.parse(
          // 'https://api.openweathermap.org/data/2.5/forecast?q=London,uk&APPID=9d7a373ab3784f4aa16b36b234c6226d'));
          'https://api.openweathermap.org/data/2.5/forecast?q=$CityName,uk&APPID=$OpenWeatherAPIKey'));
      print(res.body);
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw "An Unexpected Error Occured";
      }
      // data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Weather App",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
              onPressed: () => {
                    print("Refresh"),
                    setState(() {
                      weather;
                    })
                  },
              icon: const Icon(Icons.refresh)),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {  //checking for waiting state
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) { //checking for error
            return Center(child: Text(snapshot.error.toString()));
          }
          final data = snapshot.data!;
          final CurrentWeatherData = data['list'][0];
          final CurrentTemp = CurrentWeatherData['main']['temp'];
          final CurrentSky = CurrentWeatherData['weather'][0]['main'];
          final CurrentHumidity = CurrentWeatherData['main']['humidity'];
          final CurrentPressure = CurrentWeatherData['main']['pressure'];
          final CurrentWindSpeed = CurrentWeatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              //Main Card
              SizedBox(
                width: double.infinity,
                child: Card(
                  // elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text( 
                              '$CurrentTemp K',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 32),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Icon(
                              CurrentSky == 'Clouds' || CurrentSky == 'Rain'
                                  ? Icons.cloud
                                  : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              "$CurrentSky ",
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              //Weather Forecast Cards
              const Text(
                "Hourly Foresact",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for (int i = 0; i < 39; i++)
              //         HourlyForecastItem(
              //           time: data['list'][i + 1]['dt'].toString(),
              //           icon: data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Clouds' ||
              //                   data['list'][i + 1]['weather'][0]['main'] ==
              //                       'Rain'
              //               ? Icons.cloud
              //               : Icons.sunny,
              //           value: data['list'][i + 1]['main']['temp'].toString(),
              //         )
              //     ],
              //   ),
              // ), 

              SizedBox(
                height: 120,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      final HourlyForecast = data['list'][index + 1];
                      final hoursky =
                          data['list'][index + 1]['weather'][0]['main'];
                      final hourlytemp =
                          HourlyForecast['main']['temp'].toString();
                      final time = DateTime.parse(HourlyForecast['dt_txt']);
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon: hoursky == 'Clouds' || hoursky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                        value: hourlytemp,
                      );
                    }),
              ),
              const SizedBox(
                height: 20,
              ),
              //Additional Info Tasks
              const Text(
                "Additional Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '$CurrentHumidity',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: 'Wind Speed',
                    value: '$CurrentWindSpeed ',
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: 'Pressure',
                    value: '$CurrentPressure',
                  ),
                ],
              )
            ]),
          );
        },
      ),
    );
  }
}
