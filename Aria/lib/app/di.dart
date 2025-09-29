// lib/app/di.dart
import 'package:aria/core/network/dio_client.dart';
import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppDI {
  static DioClient buildDioClient() {
    const baseUrl = String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8000');
    return DioClient(baseUrl: baseUrl);
  }

  static List<SingleChildWidget> providers() {
    final dio = buildDioClient();

    final authRemote = AuthRemoteDataSource(dio);

    final AuthRepository authRepo = AuthRepositoryImpl(authRemote);

    return [
      ChangeNotifierProvider<AuthController>(
        create: (_) => AuthController(authRepo),
      ),
      Provider<AuthRepository>.value(value: authRepo),
    ];
  }
}
