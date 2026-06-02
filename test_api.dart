import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  try {
    final response = await dio.get(
      'http://88.222.245.145:4000/api/get_posts',
      queryParameters: {
        'type': 'take',
        'page': 1,
        'limit': 10,
        'latitude': 28.6139,
        'longitude': 77.2090,
        'distance_km': 1000.0,
      },
    );
    print(response.data);
  } catch (e) {
    print(e);
  }
}
