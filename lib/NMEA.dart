import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

class NMEA {
  String nmea_buf, nmea_buf2;
  String data;
  int commacount, lastcomma, nextcomma;
  bool rightsentence;
  bool gpsgood, gotsentence;
  double lat, lon, sog, cog;
  String gpsStats;

  Future<bool> processString(String sentence) async {
    int ii, jj;
    String chksent, chkmade;
    int chkcalc;
    Uint8List asciisent;
    for (ii = 0; ii < sentence.length; ii++) {
      data = sentence.substring(ii, ii + 1);
      switch (data) {
        case '\$': // new sentence
          nmea_buf = ''; // clear data
          break;
        case '\r': // end of sentence is  \r\n
          // checksum calculation
          if (nmea_buf.substring(nmea_buf.length - 3, (nmea_buf.length) - 2) == '*') {
            // checksum exists
            chksent = nmea_buf.substring(nmea_buf.length - 2);
            asciisent = utf8.encode(nmea_buf); //Encoding.ASCII.GetBytes(nmea_buf);
            var asciiChar = utf8.encode(chksent);
            // calculate checksum (Xor of chars between $ and *)
            chkcalc = 0;
            for (jj = 0; jj < nmea_buf.length - 3; jj++) {
              chkcalc ^= asciisent[jj];
            }
            chkmade = chkcalc.toString(); //("X2");
            if (chkmade == hex.decode(chksent).single.toString()) {
              await nmeaparse();
            }
          }
          break;
        default: // everything else
          nmea_buf += data;
          break;
      };
    }
    return true;
  }

  Future<void> nmeaparse() async {
    int ii;
    commacount = 0;
    nextcomma = -1;
    for (ii = 0; ii < nmea_buf.length; ii++) {
      data = nmea_buf.substring(ii, ii + 1);
      if (data == ',') {
        // save comma locations in string
        // there are probably string functions to do all this...
        lastcomma = nextcomma;
        nextcomma = ii;
        // this substring is the data between the commas
        nmea_buf2 =
            nmea_buf.substring(lastcomma + 1, nextcomma); // - lastcomma - 1);
        switch (commacount) {
          case 0: // 'GPRMC'
            rightsentence = nmea_buf2 == 'GPRMC'; // is that what we have?
            break;
          case 2: // A=Good, V=bad
            gpsgood = nmea_buf2 == 'A'; //
            break;
          case 3: // lat   ddmm.mmm
            if (rightsentence && gpsgood) {
              String latitud = '';
              latitud += '${nmea_buf2.substring(0, 2)}';
              var value1 = double.parse(latitud);
              var value2 = double.parse(nmea_buf2.substring(2)) / 60.0;
              latitud = (value1 + value2).toString();
              //latitud += (double.parse(nmea_buf2.substring(2)) / 60.0).toString().replaceAll(',', '');
              lat = double.parse(latitud);
            }
            break;
          case 4: // lat sign
            if (rightsentence) {
              if (nmea_buf2 == 'S') {
                // default to northern hemisphere
                lat = -lat;
              }
            }
            break;
          case 5: // lon dddmm.mmm
            if (rightsentence && gpsgood) {
              /*lon = Convert.ToDouble(nmea_buf2.Substring(0, 3));
                    lon += Convert.ToDouble(nmea_buf2.Substring(3)) / 60d;*/

              String longitud = '';
              longitud += '${nmea_buf2.substring(0, 3)}';
              var value1 = double.parse(longitud);
              var value2 = double.parse(nmea_buf2.substring(3)) / 60.0;
              longitud = (value1 + value2).toString();
              //longitud += (double.parse(nmea_buf2.substring(3)) / 60.0).toString().replaceAll(',', '');
              lon = double.parse(longitud);
            }
            break;
          case 6: // lon sign
            if (rightsentence) {
              if (nmea_buf2 == 'W') {
                // default to Eastern hemisphere
                lon = -lon;
              }
            }
            break;
          case 7: // sog XXX.X kt
            if (rightsentence && gpsgood) {
              sog = double.parse(nmea_buf2);
              print('Sog: ${nmea_buf2}');
            }
            break;
          case 8: // cog XXX.X deg
            if (rightsentence && gpsgood) {
              cog = double.parse(nmea_buf2);
              gotsentence = true;
            }
            break;
        } // switch commacount
        commacount++;
      } // if ","
    }
    print('latitud: $lat');
    print('longitud: $lon');
  }
}

class GPSStats {
  String gpsStats;
  String imei;

  String get gPSSTATS => gpsStats;

  set iMEI(String val) {
    imei = val;
  }
}
