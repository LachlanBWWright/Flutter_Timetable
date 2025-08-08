import 'package:flutter/material.dart';
import 'package:lbww_flutter/utils/date_time_utils.dart';

class TripLegDetailScreen extends StatelessWidget {
  final dynamic leg;
  const TripLegDetailScreen({super.key, required this.leg});

  @override
  Widget build(BuildContext context) {
    final transportClass = leg['transportation']['product']['class'] as int?;
    final originName =
        leg['origin']['disassembledName'] ?? leg['origin']['name'];
    final destinationName =
        leg['destination']['disassembledName'] ?? leg['destination']['name'];
    final transportName = leg['transportation']['name'] ??
        leg['transportation']['disassembledName'] ??
        '';
    final stopSequence = leg['stopSequence'] as List?;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Leg Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: $originName',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('To: $destinationName',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (transportName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Service: $transportName'),
              ],
              const SizedBox(height: 16),
              const Text('Stops:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (stopSequence != null && stopSequence.isNotEmpty)
                ...stopSequence.map<Widget>((stop) {
                  final stopName = stop['disassembledName'] ?? stop['name'];
                  final stopTime = stop['departureTimePlanned'] != null
                      ? DateTimeUtils.parseTime(stop['departureTimePlanned'])
                      : '(TBD)';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Text('$stopName $stopTime'),
                  );
                })
              else
                const Text('Walk!'),
            ],
          ),
        ),
      ),
    );
  }
}
