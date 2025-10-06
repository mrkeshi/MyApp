import 'package:aria/core/network/dio_client.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

// auth
import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';
import 'package:aria/features/province/data/repositories/province_repository_impl.dart';
import 'package:aria/features/province/domain/repositories/province_repository.dart';
import '../features/province/data/datasource/province_remote.dart';
import '../features/province/presentation/controller/province_controller.dart';

class AppDI {
  static DioClient buildDioClient() {
    const baseUrl = String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8000');
    return DioClient(baseUrl: baseUrl);
  }

  static List<SingleChildWidget> providers() {
    final dio = buildDioClient();

    // auth wiring
    final authRemote = AuthRemoteDataSource(dio);
    final AuthRepository authRepo = AuthRepositoryImpl(authRemote);


    final provinceRemote = ProvinceRemote(dio.dio);
    final ProvinceRepository provinceRepo = ProvinceRepositoryImpl(provinceRemote);

    return [
      ChangeNotifierProvider<AuthController>(
        create: (_) => AuthController(authRepo),
      ),
      ChangeNotifierProvider<ProvinceController>(
        create: (_) => ProvinceController(provinceRepo),
      ),

      Provider<AuthRepository>.value(value: authRepo),
      Provider<ProvinceRepository>.value(value: provinceRepo),
    ];
  }
}
