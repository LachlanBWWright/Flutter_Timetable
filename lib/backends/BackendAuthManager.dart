import 'package:lbww_flutter/backends/RealtimeAlertsV2Api.dart' as alerts_v2;
import 'package:lbww_flutter/backends/RealtimePositionsV1Api.dart'
    as positions_v1;
import 'package:lbww_flutter/backends/RealtimePositionsV2Api.dart'
    as positions_v2;
import 'package:lbww_flutter/backends/RealtimeTimetablesV1Api.dart'
    as timetables_v1;
import 'package:lbww_flutter/backends/RealtimeTimetablesV2Api.dart'
    as timetables_v2;
import 'package:lbww_flutter/backends/RealtimeTripUpdateV1Api.dart'
    as trip_update_v1;
import 'package:lbww_flutter/backends/RealtimeTripUpdateV2Api.dart'
    as trip_update_v2;
import 'package:lbww_flutter/backends/TripPlannerApi.dart' as trip_planner;

void addBackendAuthToAll(String apiKey) {
  trip_planner.removeBackendAuth();
  alerts_v2.removeBackendAuth();
  positions_v1.removeBackendAuth();
  positions_v2.removeBackendAuth();
  timetables_v1.removeBackendAuth();
  timetables_v2.removeBackendAuth();
  trip_update_v1.removeBackendAuth();
  trip_update_v2.removeBackendAuth();

  trip_planner.addBackendAuth(apiKey);
  alerts_v2.addBackendAuth(apiKey);
  positions_v1.addBackendAuth(apiKey);
  positions_v2.addBackendAuth(apiKey);
  timetables_v1.addBackendAuth(apiKey);
  timetables_v2.addBackendAuth(apiKey);
  trip_update_v1.addBackendAuth(apiKey);
  trip_update_v2.addBackendAuth(apiKey);
}
