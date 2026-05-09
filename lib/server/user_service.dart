import 'dart:convert';

import 'common_service.dart';
import 'package:http/http.dart' as http;

Future<({String email, int numOfSheetMusic, List<String> favoriteAuthors})>
getProfileInfo() async {
  final authHeaderFuture = await getAuthHeader();
  return http
      .get(Uri.parse('$urlCommon/profile'), headers: authHeaderFuture)
      .then((response) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final email = data['email'] as String;
          final numOfSheetMusic = data['num_of_sheet_music'] as int;
          final favoriteAuthors = (data['favorite_authors'] as List<dynamic>)
              .cast<String>();
          return (
            email: email,
            numOfSheetMusic: numOfSheetMusic,
            favoriteAuthors: favoriteAuthors,
          );
        } else {
          throw Exception('Failed to load profile info: ${response.body}');
        }
      });
}
