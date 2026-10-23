part of '../transport_api_service_impl.dart';

class Transportation {
  final String? description;
  final TransportationDestination? destination;
  final String? disassembledName;
  final int? iconId;
  final String? id;
  final String? name;
  final String? number;
  final Operator? operator;
  final Product? product;
  final TransportationProperties? properties;
  // Raw JSON used to create this `Transportation` instance.
  final Map<String, dynamic> rawJson;

  Transportation({
    this.description,
    this.destination,
    this.disassembledName,
    this.iconId,
    this.id,
    this.name,
    this.number,
    this.operator,
    this.product,
    this.properties,
    this.rawJson = const <String, dynamic>{},
  });

  factory Transportation.fromJson(Map<String, dynamic> json) {
    TransportationDestination? destination;
    final destinationJson = tryReadJsonMap(json, 'destination');
    if (destinationJson != null) {
      destination = TransportationDestination.fromJson(destinationJson);
    }

    Operator? operator;
    final operatorJson = tryReadJsonMap(json, 'operator');
    if (operatorJson != null) {
      operator = Operator.fromJson(operatorJson);
    }

    Product? product;
    final productJson = tryReadJsonMap(json, 'product');
    if (productJson != null) {
      product = Product.fromJson(productJson);
    }

    TransportationProperties? properties;
    final propertiesJson = tryReadJsonMap(json, 'properties');
    if (propertiesJson != null) {
      properties = TransportationProperties.fromJson(propertiesJson);
    }

    return Transportation(
      description: tryReadStringValue(json, 'description'),
      destination: destination,
      disassembledName: tryReadStringValue(json, 'disassembledName'),
      iconId: tryParseIntValue(tryReadMapValue(json, 'iconId')),
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
      number: tryReadStringValue(json, 'number'),
      operator: operator,
      product: product,
      properties: properties,
      rawJson: json,
    );
  }
}

class TransportationDestination {
  final String? id;
  final String? name;

  TransportationDestination({this.id, this.name});

  factory TransportationDestination.fromJson(Map<String, dynamic> json) {
    return TransportationDestination(
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class Operator {
  final String? id;
  final String? name;

  Operator({this.id, this.name});

  factory Operator.fromJson(Map<String, dynamic> json) {
    return Operator(
      id: tryReadStringValue(json, 'id'),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class Product {
  final int? classField;
  final int? iconId;
  final String? name;

  Product({this.classField, this.iconId, this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      classField: tryParseIntValue(tryReadMapValue(json, 'class')),
      iconId: tryParseIntValue(tryReadMapValue(json, 'iconId')),
      name: tryReadStringValue(json, 'name'),
    );
  }
}

class TransportationProperties {
  final bool? isTTB;
  final int? tripCode;

  TransportationProperties({this.isTTB, this.tripCode});

  factory TransportationProperties.fromJson(Map<String, dynamic> json) {
    return TransportationProperties(
      isTTB: _readBoolValue(json, 'isTTB'),
      tripCode: tryParseIntValue(tryReadMapValue(json, 'tripCode')),
    );
  }
}
