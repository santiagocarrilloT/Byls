import 'package:byls_app/services/exchange_rate.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversorService {
  static const String apiKey = '329959b7c648ffd75dca46ae70fadc1f';
  static const String apiUrl = 'http://apilayer.net/api/live';

  Future<ExchangeRate> getChangeRate(String from, String to) async {
    final url =
        '$apiUrl?access_key=$apiKey&currencies=$to&source=$from&format=1';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success']) {
        return ExchangeRate.fromJson(jsonResponse, from, to);
      } else {
        throw Exception('Error: ${jsonResponse['error']['info']}');
      }
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }
}
