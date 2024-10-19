import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<dynamic>> fetchLoanData() async {
    final response = await http.get(Uri.parse('https://api.mocklets.com/p6764/test_mint'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['items'] as List<dynamic>;
    } else {
      throw Exception('Failed to load data');
    }
  }
}