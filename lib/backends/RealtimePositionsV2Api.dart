import 'dart:async';
import 'package:chopper/chopper.dart';
import 'package:lbww_flutter/swagger_output/realtime_positions_v2.swagger.dart';

final realtimePositionsV2Api = RealtimePositionsV2.create();

void addBackendAuth(String apiKey) {
  final authInterceptor = AuthInterceptor(apiKey);
  realtimePositionsV2Api.client.interceptors.add(authInterceptor);
}

void removeBackendAuth() {
  realtimePositionsV2Api.client.interceptors.removeWhere(
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
