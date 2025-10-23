import '../../domain/entities/province.dart';

class ProvinceDto {
  final int id;
  final String nameFa;
  final String nameEn;
  final String capital;
  final String population;
  final String area;
  final String description;
  final String mapImage;

  const ProvinceDto({
    required this.id,
    required this.nameFa,
    required this.nameEn,
    required this.capital,
    required this.population,
    required this.area,
    required this.description,
    required this.mapImage,
  });

  factory ProvinceDto.fromJson(Map<String, dynamic> json) {
    return ProvinceDto(
      id: (json['id'] ?? 0) as int,
      nameFa: (json['name_fa'] ?? '') as String,
      nameEn: (json['name_en'] ?? '') as String,
      capital: (json['capital'] ?? '') as String,
      population: (json['population'] ?? '') as String,
      area: (json['area'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      mapImage: (json['map_image'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_fa': nameFa,
      'name_en': nameEn,
      'capital': capital,
      'population': population,
      'area': area,
      'description': description,
      'map_image': mapImage,
    };
  }

  Province toEntity() {
    return Province(
      id: id,
      nameFa: nameFa,
      nameEn: nameEn,
      capital: capital,
      population: population,
      area: area,
      description: description,
      mapImage: mapImage,
    );
  }
}