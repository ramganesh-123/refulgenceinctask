import 'package:dio/dio.dart';
import 'package:ecommerce_app/services/apiservices.dart';
import 'package:ecommerce_app/services/localservice.dart';
import 'package:ecommerce_app/services/repository.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  getIt.registerLazySingleton<ApiService>(
    () => ApiService(getIt<Dio>()),
  );

  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepository(
      getIt<ApiService>(),
      getIt<LocalStorageService>(),
    ),
  );
}
