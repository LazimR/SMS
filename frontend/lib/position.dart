import 'package:geolocator/geolocator.dart';

Future<Position> userPosition() async{
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if(!serviceEnabled){
    return Future.error("Sistema de Localização desativado");
  }

  permission = await Geolocator.checkPermission();

  if(permission == LocationPermission.denied){
    permission = await Geolocator.requestPermission();

    if(permission == LocationPermission.denied){
      return Future.error("Permissão de localização negada");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Permissão de localização está permanentemente negada');
  } 

  return Geolocator.getCurrentPosition();
}