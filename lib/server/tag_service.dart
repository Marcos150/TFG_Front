import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tfg/models/tag.dart';
import 'common_service.dart';

const _url = '$urlCommon/tag';

Future<List<Tag>> getAllTags() async {
  final response = await http.get(Uri.parse(_url), headers: headersReceive);

  if (response.statusCode == 200) {
    final List<dynamic> list = jsonDecode(response.body);
    final List<Tag> result = [];
    for (final tag in list) {
      result.add(Tag.fromJson(tag));
    }
    return result;
  } else {
    throw Exception('Failed to load tags');
  }
}
