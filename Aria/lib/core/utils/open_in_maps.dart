import 'package:url_launcher/url_launcher.dart';

Future<void> openInMaps({
  required double lat,
  required double lng,
  String? label,
}) async {
  final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng(${Uri.encodeComponent(label ?? '')})');
  final mapsWeb = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

  if (await canLaunchUrl(geoUri)) {
    await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    return;
  }
  if (await canLaunchUrl(mapsWeb)) {
    await launchUrl(mapsWeb, mode: LaunchMode.externalApplication);
    return;
  }
  await launchUrl(mapsWeb, mode: LaunchMode.platformDefault);
}
