import 'dart:convert';
import 'dart:io';
import 'package:convert/convert.dart';

class UdpCommunication{

  RawDatagramSocket sck;

  Future<RawDatagramSocket> configuration() async {
    await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4444).then((RawDatagramSocket socket){
      print('Encendido');
      sck = socket;
    });
    return sck;
  }

  Future<void> sending(RawDatagramSocket socket) async {
    //envia datos
    var line = stdin.readLineSync();
    var asciiData = utf8.encode(line);
    socket.send(asciiData, InternetAddress('192.168.1.7'), 4444);
    await Future.delayed(Duration(seconds: 3));
    await sending(socket);
  }

  Future<void> receive(RawDatagramSocket socket) async {
    //recibe datos
    socket.listen((RawSocketEvent e){
      Datagram d = socket.receive();
      if (d == null) return;
      String message = new String.fromCharCodes(d.data);
      print('Datagram from ${d.address.address}:${d.port}: ${message.trim()}');
    });
  }
}