import 'dart:collection';
import 'dart:convert';
import 'package:ari_utils/ari_utils.dart';
import 'package:collection/collection.dart';

//<editor-fold desc="Annotations">
class Dataclass {
  final bool? eq;
  final bool? toJson;
  final bool? fromJson;
  final bool? attributes;
  final bool? toStr;
  final bool? copyWith;
  final bool? all;
  final String? superFactory;

  // final bool
  const Dataclass(
      {this.eq,
      this.toJson,
      this.fromJson,
      this.attributes,
      this.toStr,
      this.copyWith,
      this.all,
      this.superFactory});
}

class Default {
  final Object value;

  const Default(this.value);
}

class Super {
  /// Type + for positional parameter and do ++s relative its position.
  /// However doing an incorrect number of ++s will give an error.
  // final Type parent;
  final String param;

  const Super(this.param);
}
//</editor-fold>

// <editor-fold desc="Reflected Meta-classes from Python">
class DartType {
  String type;
  late List<DartType> generics;

//<editor-fold desc="Data Methods">

  DartType({
    required this.type,
    required this.generics,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DartType &&
          runtimeType.toString() == other.runtimeType.toString() &&
          type.runtimeType == other.type.runtimeType &&
          type.toString() == other.type.toString() &&
          generics.runtimeType == other.generics.runtimeType &&
          generics.toString() == other.generics.toString());

  @override
  int get hashCode => type.hashCode ^ generics.hashCode;

  @override
  String toString() {
    return 'DartType{'
        'type: $type'
        'generics: $generics}';
  }

  DartType copyWith({
    String? type_,
    List<DartType>? generics_,
  }) {
    return DartType(
        type: type_ ?? type, generics: generics_ ?? List.from(generics));
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'generics': generics,
    };
  }

  factory DartType.fromMap(Map<String, dynamic> map) {
    return DartType(
      type: map['type'] as String,
      generics: map['generics'] as List<DartType>,
    );
  }

//</editor-fold>
}

class Attribute {}
//</editor-fold>

// Help Functions
// const List<Type> mapTypes = [Map, HashMap, LinkedHashMap, SplayTreeMap, UnmodifiableMapView];
bool isMap(i) =>
    i is Map ||
    i is HashMap ||
    i is LinkedHashMap ||
    i is SplayTreeMap ||
    i is UnmodifiableMapView;

bool equals(a, b) {
  DeepCollectionEquality deepEquality = const DeepCollectionEquality();
  if (a.runtimeType == b.runtimeType) {
    if (a is Iterable
        // a is List
        //     || a is Set
        //     || a is Map
        //     || a is Queue
        //     || a is LinkedHashMap
        //     || a is LinkedHashSet
        //     || a is Array
        //     || a is HashMap

        ) {
      return deepEquality.equals(a, b);
    }
  }
  return a == b;
}

bool isJsonSafe(a) => a == null || a is num || a is String || a is bool;

jsonify(thing) {
  try {
    thing.toJson();
  } on NoSuchMethodError {
    if (isJsonSafe(thing)) {
      return thing;
    }
    else if (thing is Iterable && !isMap(thing)) {
      return nestedJsonList(thing);
    } //todo expand types
    else if (thing is Iterable) {
      return nestedJsonMap(thing);
    } //todo expand types and add nested map function
    // add more conditions?
    else {
      throw Exception('Error on handling $thing since ${thing.runtimeType} '
          'is not a base class or does not have a toJson() method');
    }
  }
}

List nestedJsonList(Iterable iter) {
  List l = [];
  for (var thing in iter) {
    l.add(jsonify(thing));
  }
  return l;
}

Map nestedJsonMap(mapLikeThing) {
  Map m = {};
  var key;
  var value;
  for (MapEntry mapEntry in mapLikeThing.entries) {
    if (isJsonSafe(mapEntry.key)) {
      key = mapEntry.key;
    } else {
      try {
        key = mapEntry.key.toJson();
      } on NoSuchMethodError {
        throw Exception(
            'Error on handling ${mapEntry.key} since ${mapEntry.key.runtimeType} '
            'is not a base class or does not have a toJson() method');
      }
    }
    if (isJsonSafe(mapEntry.value)) {
      value = mapEntry.value;
    } else {
      try {
        value = mapEntry.value.toJson();
      } on NoSuchMethodError {
        if (mapEntry.value is Iterable) {
          value = nestedJsonList(mapEntry.value);
        } else {
          throw Exception(
              'Error on handling ${mapEntry.value} since ${mapEntry.value.runtimeType} '
              'is not a base class or does not have a toJson() method');
        }
      }
    }
    m[key] = value;
  }
  return m;
}

Cast caster<Cast>(item) {
  String string = '$Cast';
  // if (string.contains('<')){
  //   String parentTypeString = string.splitByNumber(RegExp('<'), number: 1)[0].trim();
  //   Type parentType = iterable2type[parentTypeString]!;
  //   return iterableInstantiator[parentType]!<Generic>(item);
  // }
  print(string);
  return iterableInstantiator[Cast]!(item);
}

Cast listCasterGeneric<Cast extends Iterable, Generic>(item) {
  String string = '$Cast';
  String parentTypeString = string.contains('<')
      ? string.splitByNumber(RegExp('<'), number: 1)[0].trim()
      : string.trim();
  Type parentType = iterable2type[parentTypeString]!;
  return iterableInstantiator[parentType]!<Generic>(item);
}

Cast mapCasterGeneric<Cast, K, V>(item) {
  String string = '$Cast';
  String parentTypeString =
      string.splitByNumber(RegExp('<'), number: 1)[0].trim();
  Type parentType = iterable2type[parentTypeString]!;
  return iterableInstantiator[parentType]!<K, V>(item);
}

// <editor-fold desc="JSON Extensions">
extension DateTimeJson on DateTime {
  String toJson() =>
      jsonEncode({'time': toIso8601String(), '__type': 'DateTime'});

  static DateTime fromMap(Map map) => DateTime.parse(map['time']!);

  static DateTime fromJson(String json) =>
      DateTimeJson.fromMap(jsonDecode(json));
}

extension UriJson on Uri {
  String toJson() => jsonEncode({'__type': 'Uri', 'url': toString()});

  static Uri fromJson(String json) => UriJson.fromMap(jsonDecode(json));

  static Uri fromMap(Map map) => Uri.parse(map['url']!);
}

extension BigIntJson on BigInt {
  String toJson() => jsonEncode({'__type': 'BigInt', 'int': toString()});

  static BigInt fromJson(String json) => BigIntJson.fromMap(jsonDecode(json));

  static BigInt fromMap(Map map) => BigInt.parse(map['int']!);
}

extension DurationJson on Duration {
  String toJson() =>
      jsonEncode({'__type': 'Duration', 'duration': inMicroseconds});

  static Duration fromMap(Map map) => Duration(microseconds: map['duration']!);

  static Duration fromJson(String json) =>
      DurationJson.fromMap(jsonDecode(json));
}

extension RegExpJson on RegExp {
  String toJson() => jsonEncode(
      {'__type': 'RegExp', 'pattern': pattern, 'multiline': isMultiLine});

  static RegExp fromMap(Map map) =>
      RegExp(map['pattern'], multiLine: map['multiline'] ?? false);

  static RegExp fromJson(String json) => RegExpJson.fromMap(jsonDecode(json));
}

const Map<String, Function> typeFactoryDefault = {
  'Uri': UriJson.fromMap,
  'DateTime': DateTimeJson.fromMap,
  'BigInt': BigIntJson.fromMap,
  'Duration': DurationJson.fromMap,
  'RegExp': RegExpJson.fromMap
};

const Map<Type, Function> iterableInstantiator = {
  List: List.from,
  Map: Map.from,
  Set: Set.from,
  Iterable: Iterable.castFrom,
  HashMap: HashMap.from,
  LinkedHashSet: LinkedHashSet.from,
  LinkedHashMap: LinkedHashMap.from,
  Queue: Queue.from,
  ListQueue: ListQueue.from,
  SplayTreeSet: SplayTreeSet.from,
};
const Map<String, Type> iterable2type = {
  'List': List,
  'Map': Map,
  'Set': Set,
  'Iterable': Iterable,
  'HashMap': HashMap,
  'LinkedHashSet': LinkedHashSet,
  'LinkedHashMap': LinkedHashMap,
  'Queue': Queue,
  'ListQueue': ListQueue,
  'SplayTreeSet': SplayTreeSet,
};
// </editor-fold>
