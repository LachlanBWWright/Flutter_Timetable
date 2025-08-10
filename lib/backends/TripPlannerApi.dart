import 'dart:async';

import 'package:chopper/chopper.dart';
import 'package:lbww_flutter/swagger_output/trip_planner.swagger.dart';

final tripPlannerApi = TripPlanner.create();

void addBackendAuth(String apiKey) {
  final authInterceptor = AuthInterceptor(apiKey);

  tripPlannerApi.client.interceptors.add(authInterceptor);
}

void removeBackendAuth() {
  tripPlannerApi.client.interceptors.removeWhere(
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
