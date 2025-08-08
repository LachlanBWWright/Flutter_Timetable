import 'package:flutter/material.dart';
import 'package:lbww_flutter/trip_leg_screen.dart';
// import 'package:lbww_flutter/utils/date_time_utils.dart';
// import 'package:lbww_flutter/constants/transport_colors.dart';
import 'package:lbww_flutter/widgets/trip_widgets.dart' show TransportModeUtils;

/// Widget for displaying trip leg information

class TripLegCard extends StatelessWidget {
  final dynamic leg;

  const TripLegCard({
    super.key,
    required this.leg,
  });

  @override
  Widget build(BuildContext context) {
    final transportClass = leg['transportation']['product']['class'] as int;
    final originName =
        leg['origin']['disassembledName'] ?? leg['origin']['name'];
    final destinationName =
        leg['destination']['disassembledName'] ?? leg['destination']['name'];
    final transportName = leg['transportation']['name'] ??
        leg['transportation']['disassembledName'] ??
        '';
    final modeColor = TransportModeUtils.getModeColor(transportClass);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripLegDetailScreen(leg: leg),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: modeColor,
              width: 2.0,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 4.0,
              height: double.infinity,
              decoration: BoxDecoration(
                color: modeColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            title: Text(
              '(${TransportModeUtils.getModeName(transportClass)}) $originName to $destinationName',
              style: TextStyle(
                color: modeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: transportName.isNotEmpty
                ? Text(
                    transportName,
                    style: TextStyle(
                      color: modeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
