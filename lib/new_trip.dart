import 'package:csv/csv.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:lbww_flutter/schema/database.dart';
import 'package:lbww_flutter/services/transport_api_service.dart';
import 'package:lbww_flutter/widgets/station_widgets.dart';

class NewTripScreen extends StatefulWidget {
  const NewTripScreen({super.key});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  List<Station> _trainStationList = [];
  List<Station> _busStationList = [];
  List<Station> _ferryStationList = [];
  List<Station> _lightRailStationList = [];
  String _firstStation = '';
  String _firstStationId = '';
  String _secondStation = '';
  String _secondStationId = '';
  bool _isSearching = false;
  final keyController = TextEditingController();
  final AppDatabase _db = AppDatabase();

  void setStation(String station, String id) async {
    setState(() {
      if (_firstStation == '') {
        _firstStation = station;
        _firstStationId = id;
        keyController.text = '';
      } else {
        _secondStation = station;
        _secondStationId = id;
        keyController.text = '';
      }
    });
    loadStations();
  }

  void _clearFirstStation() {
    setState(() {
      _firstStation = '';
      _firstStationId = '';
    });
  }

  void _clearSecondStation() {
    setState(() {
      _secondStation = '';
      _secondStationId = '';
    });
  }

  void _toggleSearch() {
    setState(() {
      if (keyController.text == '') {
        _isSearching = !_isSearching;
      } else {
        keyController.text = '';
      }
    });
  }

  Future<void> _saveTrip() async {
    if (_firstStation.isNotEmpty && _secondStation.isNotEmpty) {
      print(
          'Attempting to save trip: $_firstStation ($_firstStationId) -> $_secondStation ($_secondStationId)');
      try {
        await _db.insertJourney(JourneysCompanion(
          origin: drift.Value(_firstStation),
          originId: drift.Value(_firstStationId),
          destination: drift.Value(_secondStation),
          destinationId: drift.Value(_secondStationId),
        ));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Saved trip from $_firstStation to $_secondStation.',
            ),
          ));
          setState(() {
            _firstStation = '';
            _firstStationId = '';
            _secondStation = '';
            _secondStationId = '';
          });
        }
      } catch (e) {
        print('Error inserting journey: $e');
      }
    }
  }

  Future<void> loadStations() async {
    final dataset =
        await rootBundle.loadString('assets/LocationFacilityData.csv');
    final List<dynamic> data =
        const CsvToListConverter().convert(dataset, eol: '\n');
    data.removeWhere((station) => !station[9].contains('Train'));
    //[10] - Mode
    final trainStations = List<Station>.empty(growable: true);
    final busStations = List<Station>.empty(growable: true);
    final lightRailStations = List<Station>.empty(growable: true);
    final ferryStations = List<Station>.empty(growable: true);
    for (var station in data) {
      if (station[9].contains('Train')) {
        trainStations.add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains('Bus')) {
        busStations.add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains('Light')) {
        lightRailStations
            .add(Station(name: station[0], id: station[4].toString()));
      }
      if (station[9].contains('Ferry')) {
        ferryStations.add(Station(name: station[0], id: station[4].toString()));
      }
    }

    setState(() {
      _trainStationList = trainStations;
      _busStationList = busStations;
      _lightRailStationList = lightRailStations;
      _ferryStationList = ferryStations;
    });
  }

  void loadSearchStations(String search) async {
    try {
      final results = await TransportApiService.searchStations(search);
      final stations = results
          .map((result) => Station(
                name: result.name ?? '',
                id: result.id ?? '',
              ))
          .toList();

      setState(() {
        _trainStationList = stations;
      });
    } catch (e) {
      print('Error searching stations: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadStations();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSave = _firstStation.isNotEmpty && _secondStation.isNotEmpty;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: NewTripAppBar(
          isSearching: _isSearching,
          searchController: keyController,
          onSearch: loadSearchStations,
          onToggleSearch: _toggleSearch,
          onSaveTrip: canSave ? _saveTrip : null,
          canSave: canSave,
        ),
        body: TabBarView(
          children: [
            _buildTrainStationTab(),
            StationList(
              listItems: _lightRailStationList,
              setStation: setStation,
            ),
            StationList(
              listItems: _busStationList,
              setStation: setStation,
            ),
            StationList(
              listItems: _ferryStationList,
              setStation: setStation,
            ),
            const Center(child: Text('Map functionality coming soon')),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainStationTab() {
    return Column(
      children: [
        if (_firstStation.isNotEmpty)
          SelectedStationCard(
            label: 'First Station Selected',
            stationName: _firstStation,
            onCancel: _clearFirstStation,
          ),
        if (_secondStation.isNotEmpty)
          SelectedStationCard(
            label: 'Second Station Selected',
            stationName: _secondStation,
            onCancel: _clearSecondStation,
          ),
        Expanded(
          child: StationList(
            listItems: _trainStationList,
            setStation: setStation,
          ),
        ),
      ],
    );
  }
}
