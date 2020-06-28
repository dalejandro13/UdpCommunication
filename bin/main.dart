import 'dart:core';
import 'dart:io';
//import 'package:flexorutero/NMEA.dart';
import 'package:flexorutero/UpdCommunication.dart';
//import 'package:flexorutero/flexorutero.dart' as flexorutero;

//String sentence = '\$GPRMC,233834,A,3759.842,N,12205.440,W,000.0,173.7,200602,015.8,E*63\r';
//String sentence = '\$GPRMC,230046,A,3759.8006,N,12205.4429,W,0.0,190.3,260702,15.1,E,A*3C\r';
//NMEA nm = NMEA();
UdpCommunication udp = UdpCommunication();

void main(List<String> arguments) async {
  var socket = await udp.configuration(); 
  await udp.receive(socket); 
  await udp.sending(socket);
}
