import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu/models/weather_model.dart';

class WeatherServices {
  Future<String> _getLocation() async {
    // konum izni açıkmı kontrol ettik
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Future.error("Konum Servisiniz Kapalı");
    }

    //kullanıcı konum izni varmı kontrol ettik
    var permission = await Geolocator.checkPermission();
    //konum izni vermemişse tekrar istedik
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      //konum izni vermediyse hata verdik
      if (permission == LocationPermission.denied) {
        Future.error("Konum izni vermelisiniz");
      }
    }
    // kullanıcının pozisyonunu aldık
    final position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    //kullanıcının yerleşim yerini bulduk
    final List<Placemark> placemark = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    // şehrimizi yerleşim noktasına kaydettik
    final String? city = placemark[0].administrativeArea;

    if (city == null) {
      Future.error("Bir sorun oluştu");
    }

    return city ?? "";
  }

  Future<List<WeatherModel>> getWeatherData() async {
    final String city = await _getLocation();

    final String url =
        'https://api.collectapi.com/weather/getWeather?data.lang=tr&data.city=$city';

    const Map<String, dynamic> headers = {
      'authorization': 'apikey 5ABZlmrXuAnlvuJSuVv33Z:7pbx7fTZlHdl2tff2J9fNb',
      'content-type': 'application/json',
    };

    final dio = Dio();

    final response = await dio.get(url, options: Options(headers: headers));

    if (response.statusCode != 200) {
      return Future.error("Bir sorun oluştu");
    }

    final List list = response.data['result'];
    final List<WeatherModel> weatherlist = list
        .map((e) => WeatherModel.fromJson(e))
        .toList();
    return weatherlist;
  }
}
