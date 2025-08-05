import 'package:flutter/material.dart';

/// Transport Network Colors based on official NSW Transport branding
class TransportColors {
  // Sydney Metro
  static const Color metroM = Color(0xFF168388); // M LINE
  
  // Sydney Trains
  static const Color trainsT1 = Color(0xFFF99D1C); // T1 LINE
  static const Color trainsT2 = Color(0xFF0098CD); // T2 LINE
  static const Color trainsT3 = Color(0xFFF37021); // T3 LINE
  static const Color trainsT4 = Color(0xFF005AA3); // T4 LINE
  static const Color trainsT5 = Color(0xFFC4258F); // T5 LINE
  static const Color trainsT7 = Color(0xFF6F818E); // T7 LINE
  static const Color trainsT8 = Color(0xFF00954C); // T8 LINE
  static const Color trainsT9 = Color(0xFFD11F2F); // T9 LINE
  
  // Intercity Trains
  static const Color blueMountains = Color(0xFFF99D1C); // BLUE MOUNTAINS
  static const Color centralCoastNewcastle = Color(0xFFD11F2F); // CENTRAL COAST & NEWCASTLE
  static const Color hunter = Color(0xFF833134); // HUNTER
  static const Color southCoast = Color(0xFF005AA3); // SOUTH COAST
  static const Color southernHighlands = Color(0xFF00954C); // SOUTHERN HIGHLANDS
  
  // Regional Trains and Coaches Network
  static const Color regionalTrains = Color(0xFFF6891F); // TRAINS
  static const Color regionalCoaches = Color(0xFF732A82); // COACHES
  
  // Sydney Ferries
  static const Color ferryF1 = Color(0xFF00774B); // F1 MANLY
  static const Color ferryF2 = Color(0xFF144734); // F2 TARONGA ZOO
  static const Color ferryF3 = Color(0xFF648C3C); // F3 PARRAMATTA RIVER
  static const Color ferryF4 = Color(0xFFBFD730); // F4 PYRMONT BAY
  static const Color ferryF5 = Color(0xFF286142); // F5 NEUTRAL BAY
  static const Color ferryF6 = Color(0xFF00AB51); // F6 MOSMAN BAY
  static const Color ferryF7 = Color(0xFF00B189); // F7 DOUBLE BAY
  static const Color ferryF8 = Color(0xFF55622B); // F8 COCKATOO ISLAND
  static const Color ferryF9 = Color(0xFF65B32E); // F9 WATSONS BAY
  static const Color ferryF10 = Color(0xFF5AB031); // F10 BLACKWATTLE BAY
  
  // Newcastle Ferries
  static const Color newcastleFerry = Color(0xFF5AB031); // STKN Stockton
  
  // Sydney Light Rail
  static const Color lightRailL1 = Color(0xFFBE1622); // L1 DULWICH HILL LINE
  static const Color lightRailL2 = Color(0xFFDD1E25); // L2 RANDWICK LINE
  static const Color lightRailL3 = Color(0xFF781140); // L3 KINGSFORD LINE
  static const Color newcastleLightRail = Color(0xFFEE343F); // NLR NEWCASTLE LIGHT RAIL
  
  // Generic mode colors for UI
  static const Color bus = Color(0xFF0098CD); // Generic bus blue
  static const Color train = Color(0xFFF99D1C); // Generic train orange
  static const Color ferry = Color(0xFF00954C); // Generic ferry green
  static const Color lightRail = Color(0xFFBE1622); // Generic light rail red
  static const Color metro = Color(0xFF168388); // Metro teal
  static const Color coach = Color(0xFF732A82); // Coach purple
  
  /// Get color by transport mode
  static Color getColorByMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'bus':
        return bus;
      case 'train':
        return train;
      case 'ferry':
        return ferry;
      case 'lightrail':
      case 'light rail':
        return lightRail;
      case 'metro':
        return metro;
      case 'coach':
        return coach;
      default:
        return Colors.grey;
    }
  }
  
  /// Get color by specific line/route
  static Color getColorByLine(String line) {
    switch (line.toUpperCase()) {
      // Sydney Trains
      case 'T1':
        return trainsT1;
      case 'T2':
        return trainsT2;
      case 'T3':
        return trainsT3;
      case 'T4':
        return trainsT4;
      case 'T5':
        return trainsT5;
      case 'T7':
        return trainsT7;
      case 'T8':
        return trainsT8;
      case 'T9':
        return trainsT9;
        
      // Metro
      case 'M':
      case 'METRO':
        return metroM;
        
      // Light Rail
      case 'L1':
        return lightRailL1;
      case 'L2':
        return lightRailL2;
      case 'L3':
        return lightRailL3;
      case 'NLR':
        return newcastleLightRail;
        
      // Ferries
      case 'F1':
        return ferryF1;
      case 'F2':
        return ferryF2;
      case 'F3':
        return ferryF3;
      case 'F4':
        return ferryF4;
      case 'F5':
        return ferryF5;
      case 'F6':
        return ferryF6;
      case 'F7':
        return ferryF7;
      case 'F8':
        return ferryF8;
      case 'F9':
        return ferryF9;
      case 'F10':
        return ferryF10;
        
      default:
        return Colors.grey;
    }
  }
}