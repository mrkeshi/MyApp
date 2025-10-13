import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

Future<void> openInMaps(dynamic d) async {
  final lat = (d.latitude as String).trim();
  final lon = (d.longitude as String).trim();
  if (lat.isEmpty || lon.isEmpty) return;
  final label = Uri.encodeComponent(d.title);
  final geo = Uri.parse('geo:$lat,$lon?q=${Uri.encodeComponent('$lat,$lon($label)')}');
  final apple = Uri.parse('http://maps.apple.com/?q=$lat,$lon');
  final gmaps = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lon');
  if (Platform.isAndroid && await canLaunchUrl(geo)) { await launchUrl(geo, mode: LaunchMode.externalApplication); return; }
  if (Platform.isIOS && await canLaunchUrl(apple)) { await launchUrl(apple, mode: LaunchMode.externalApplication); return; }
  if (await canLaunchUrl(gmaps)) { await launchUrl(gmaps, mode: LaunchMode.externalApplication); }
}
