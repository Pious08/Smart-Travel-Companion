import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using OpenWeatherMap API (you'll need to replace with your API key)
  static const String _apiKey = 'f5f6987c3c3cf9380462172d35fc955b';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  static Future<Map<String, dynamic>?> getWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp'],
          'feelsLike': data['main']['feels_like'],
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'humidity': data['main']['humidity'],
          'windSpeed': data['wind']['speed'],
          'cityName': data['name'],
        };
      }
    } catch (e) {
      print('Error fetching weather: $e');
    }
    return null;
  }

  static Future<List<Map<String, dynamic>>> getForecast(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> list = data['list'];
        
        return list.take(5).map((item) {
          return {
            'date': item['dt_txt'],
            'temperature': item['main']['temp'],
            'description': item['weather'][0]['description'],
            'icon': item['weather'][0]['icon'],
          };
        }).toList();
      }
    } catch (e) {
      print('Error fetching forecast: $e');
    }
    return [];
  }

  // Mock weather data for demo purposes
  static Map<String, dynamic> getMockWeather(String cityName) {
    return {
      'temperature': 25.0,
      'feelsLike': 27.0,
      'description': 'Partly cloudy',
      'icon': '02d',
      'humidity': 65,
      'windSpeed': 3.5,
      'cityName': cityName,
    };
  }
}