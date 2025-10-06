import 'package:aria/core/network/dio_client.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// auth
import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';

// province
import 'package:aria/features/province/data/repositories/province_repository_impl.dart';
import 'package:aria/features/province/domain/repositories/province_repository.dart';
import 'package:aria/features/province/presentation/controller/province_controller.dart';
import 'package:aria/features/province/data/datasource/province_remote.dart';

// gallery (NEW)
import 'package:aria/features/gallery/data/datasources/photo_remote_data_source.dart';
import 'package:aria/features/gallery/data/repositories/photo_repository_impl.dart';
import 'package:aria/features/gallery/domain/repositories/photo_repository.dart';
import 'package:aria/features/gallery/presentation/controllers/gallery_controller.dart';

class AppDI {
  static DioClient buildDioClient() {
    const baseUrl = String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8000');
    return DioClient(baseUrl: baseUrl);
  }

  static List<SingleChildWidget> providers() {
    final dioClient = buildDioClient();
    final dio = dioClient.dio;

    // auth
    final authRemote = AuthRemoteDataSource(dioClient);
    final AuthRepository authRepo = AuthRepositoryImpl(authRemote);

    // province
    final provinceRemote = ProvinceRemote(dio);
    final ProvinceRepository provinceRepo = ProvinceRepositoryImpl(provinceRemote);

    final photoRemote = PhotoRemoteDataSource(dio);
    final PhotoRepository photoRepo = PhotoRepositoryImpl(photoRemote);

    return [
      ChangeNotifierProvider<AuthController>(create: (_) => AuthController(authRepo)),
      ChangeNotifierProvider<ProvinceController>(create: (_) => ProvinceController(provinceRepo)),


      // ChangeNotifierProvider<GalleryController>(create: (_) => GalleryController(photoRepo)),

      Provider<AuthRepository>.value(value: authRepo),
      Provider<ProvinceRepository>.value(value: provinceRepo),

      Provider<PhotoRepository>.value(value: photoRepo),
    ];
  }
}
