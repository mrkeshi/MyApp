import 'package:flutter/material.dart';
import '../../../../core/utils/open_in_maps.dart';
import '../../../../shared/styles/colors.dart';

class MapSection extends StatelessWidget {
  final dynamic data;
  const MapSection({super.key, required this.data});

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Map<String, double>? _extractLatLng(dynamic d) {
    double? lat, lng;

    if (d is Map) {
      lat = _toDouble(d['lat'] ?? d['latitude'] ?? d['Lat'] ?? (d['location']?['lat']) ?? (d['location']?['latitude'])
          ?? ((d['coordinates'] is List && d['coordinates'].length >= 2) ? d['coordinates'][0] : null));
      lng = _toDouble(d['lng'] ?? d['longitude'] ?? d['Lng'] ?? (d['location']?['lng']) ?? (d['location']?['longitude'])
          ?? ((d['coordinates'] is List && d['coordinates'].length >= 2) ? d['coordinates'][1] : null));
    } else {
      try { lat = _toDouble(d.lat); } catch (_) {}
      try { lng = _toDouble(d.lng); } catch (_) {}
      try { lat = lat ?? _toDouble(d.latitude); } catch (_) {}
      try { lng = lng ?? _toDouble(d.longitude); } catch (_) {}
      try {
        final loc = d.location;
        try { lat = lat ?? _toDouble(loc.lat); } catch (_) {}
        try { lng = lng ?? _toDouble(loc.lng); } catch (_) {}
        try { lat = lat ?? _toDouble(loc.latitude); } catch (_) {}
        try { lng = lng ?? _toDouble(loc.longitude); } catch (_) {}
      } catch (_) {}
      try {
        final coords = d.coordinates;
        if (coords is List && coords.length >= 2) {
          lat = lat ?? _toDouble(coords[0]);
          lng = lng ?? _toDouble(coords[1]);
        }
      } catch (_) {}
    }

    if (lat != null && lng != null) return {'lat': lat!, 'lng': lng!};
    return null;
  }

  String? _extractLabel(dynamic d) {
    if (d is Map) {
      return (d['title'] ?? d['name'] ?? d['label'])?.toString();
    } else {
      try { return d.title?.toString(); } catch (_) {}
      try { return d.name?.toString(); } catch (_) {}
      try { return d.label?.toString(); } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final coords = _extractLatLng(data);
    final label = _extractLabel(data);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/map.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 260,
          ),
          Container(
            height: 260,
            color: Colors.black.withOpacity(0.25),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 6,
                shadowColor: primary.withOpacity(0.8),
              ),
              onPressed: (coords != null)
                  ? () => openInMaps(
                lat: coords['lat']!,
                lng: coords['lng']!,
                label: label,
              )
                  : null,
              child: const Text(
                'بازکردن در نقشه',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
