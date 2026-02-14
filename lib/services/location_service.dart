import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  // Lokasyona göre dil kodunu döndürür
  Future<String> getLanguageByLocation() async {
    try {
      // Konum izni kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'en'; // İzin verilmezse İngilizce
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'en'; // Kalıcı red, İngilizce
      }

      // Konum al
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      // Ülke kodunu al
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        String? countryCode = placemarks.first.isoCountryCode;
        return _getLanguageFromCountryCode(countryCode);
      }
    } catch (e) {
      return 'en';
    }

    return 'en';
  }

  // Ülke koduna göre dil döndür (Arapça hariç, sadece TR/EN/ID)
  String _getLanguageFromCountryCode(String? countryCode) {
    if (countryCode == null) return 'en';

    // Türkçe
    if (countryCode == 'TR') {
      return 'tr';
    }

    // Endonezce
    if (countryCode == 'ID') {
      return 'id';
    }

    // Varsayılan İngilizce (Arapça ülkeler dahil)
    return 'en';
  }
}
