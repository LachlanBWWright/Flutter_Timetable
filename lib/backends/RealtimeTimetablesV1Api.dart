import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:lbww_flutter/swagger_output/realtime_timetables_v1.swagger.dart';

final realtimeTimetablesV1Api = RealtimeTimetablesV1.create();

void addBackendAuth(String apiKey) {
  final authInterceptor = AuthInterceptor(apiKey);
  realtimeTimetablesV1Api.client.interceptors.add(authInterceptor);
}

void removeBackendAuth() {
  realtimeTimetablesV1Api.client.interceptors.removeWhere(
    (interceptor) => interceptor is AuthInterceptor,
  );
}

class AuthInterceptor implements Interceptor {
  AuthInterceptor(this.apiKey);
  final String apiKey;
  @override
  FutureOr<Response<BodyType>> intercept<BodyType>(
      Chain<BodyType> chain) async {
    final request =
        applyHeader(chain.request, 'Authorization', 'apikey $apiKey');
    return chain.proceed(request);
  }
}
