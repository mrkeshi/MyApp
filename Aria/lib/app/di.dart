import 'package:aria/core/network/dio_client.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:aria/features/auth/data/datasources/auth_remote.dart';
import 'package:aria/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:aria/features/auth/domain/repositories/auth_repository.dart';
import 'package:aria/features/auth/presentation/controllers/auth_controller.dart';

import 'package:aria/features/province/data/repositories/province_repository_impl.dart';
import 'package:aria/features/province/domain/repositories/province_repository.dart';
import 'package:aria/features/province/presentation/controller/province_controller.dart';
import 'package:aria/features/province/data/datasource/province_remote.dart';

import 'package:aria/features/gallery/data/datasources/photo_remote_data_source.dart';
import 'package:aria/features/gallery/data/repositories/photo_repository_impl.dart';
import 'package:aria/features/gallery/domain/repositories/photo_repository.dart';

import 'package:aria/features/attractions/data/datasources/attraction_remote_data_source.dart';
import 'package:aria/features/attractions/data/repositories/attraction_repository_impl.dart';
import 'package:aria/features/attractions/domain/repositories/attraction_repository.dart';
import 'package:aria/features/attractions/presentation/controller/attractions_controller.dart';
import 'package:aria/features/gallery/presentation/controllers/gallery_controller.dart';

import 'package:aria/features/home/presentation/controller/audio_controller.dart';

import 'package:aria/features/bookmark/data/datasources/bookmark_remote_data_source.dart';
import 'package:aria/features/bookmark/data/repositories/bookmark_repository_impl.dart';
import 'package:aria/features/bookmark/domain/repositories/bookmark_repository.dart';

import '../features/event/data/datasources/event_remote_data_source.dart';
import '../features/event/data/repositories/event_repository_impl.dart';
import '../features/event/domain/repositories/event_repository.dart';
import '../features/event/presentation/controller/events_controller.dart';

class AppDI {
  static DioClient buildDioClient() {
    const baseUrl =
    String.fromEnvironment('API_BASE', defaultValue: 'http://10.0.2.2:8000');
    return DioClient(baseUrl: baseUrl);
  }

  static List<SingleChildWidget> providers() {
    final dioClient = buildDioClient();
    final dio = dioClient.dio;

    final authRemote = AuthRemoteDataSource(dioClient);
    final AuthRepository authRepo = AuthRepositoryImpl(authRemote);

    final provinceRemote = ProvinceRemote(dio);
    final ProvinceRepository provinceRepo = ProvinceRepositoryImpl(provinceRemote);

    final photoRemote = PhotoRemoteDataSource(dio);
    final PhotoRepository photoRepo = PhotoRepositoryImpl(photoRemote);

    final attractionRemote = AttractionRemoteDataSource(dio);
    final AttractionRepository attractionRepo = AttractionRepositoryImpl(attractionRemote);

    final bookmarkRemote = BookmarkRemoteDataSource(dio);
    final BookmarkRepository bookmarkRepo = BookmarkRepositoryImpl(bookmarkRemote);

    final eventRemote = EventRemoteDataSource(dio);
    final EventRepository eventRepo = EventRepositoryImpl(eventRemote);

    return [
      Provider<AuthRepository>.value(value: authRepo),
      Provider<ProvinceRepository>.value(value: provinceRepo),
      Provider<PhotoRepository>.value(value: photoRepo),
      Provider<AttractionRepository>.value(value: attractionRepo),
      Provider<BookmarkRepository>.value(value: bookmarkRepo),
      Provider<EventRepository>.value(value: eventRepo),

      ChangeNotifierProvider<ProvinceController>(
        create: (_) => ProvinceController(provinceRepo),
      ),

      ChangeNotifierProxyProvider<ProvinceController, AuthController>(
        create: (ctx) => AuthController(
          ctx.read<AuthRepository>(),
          provinceRepo: ctx.read<ProvinceRepository>(),
          provinceController: ctx.read<ProvinceController>(),
        ),
        update: (ctx, provCtrl, authCtrl) => authCtrl!,
      ),

      ChangeNotifierProvider<GalleryController>(
        create: (ctx) => GalleryController(ctx.read<PhotoRepository>()),
      ),

      ChangeNotifierProvider<AudioController>(
        create: (_) => AudioController(),
      ),

      ChangeNotifierProvider<AttractionsController>(
        create: (ctx) => AttractionsController(attractionRepo),
      ),

      ChangeNotifierProvider<EventsController>(
          create: (ctx) => EventsController(
            ctx.read<EventRepository>(),
            ctx.read<BookmarkRepository>(),
          ),
      ),
    ];
  }
}
