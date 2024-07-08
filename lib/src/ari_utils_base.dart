import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

// Dependent typedefs
typedef BoolFunctionMap = bool Function(MapEntry);

// Extensions
extension NumIs on num {
  ///Checks if num is int
  bool get isInt => (this % 1) == 0;

  ///Checks if num is decimal
  bool get isDouble => !isInt;

  ///Checks if a number > 0
  bool get isPositive => this > 0;

}

extension PythonicListMethods<E> on List<E> {
  ///Returns a list slice from given list with all indices contained within the
  ///given range. START INCLUSIVE | END EXCLUSIVE. By default start=0, stop=list.length, step=1. Invalid inputs
  ///are met with ArgumentErrors.
  ///ex:
  ///```
  ///[0,1,2,3,4,5,6].slice(stop: 4) => [0,1,2,3]
  ///```
  List<E> slice({int? stop, int start = 0, int step = 1}) {
    //Defaults
    stop ??= length; //TODO FIX NEG SLICE DEFAULT
    List<E> iterationList = step.isPositive ? List<E>.from(this) : reversed.toList();
    if (step.isNegative){step *= -1;}
    //Clean Up Index (Negative and invalid start/stops)
    while (start < 0) {
      start += length;
    }
    while (stop! < 0) {
      stop += length;
    }
    if (start > length || stop > length) {
      throw ArgumentError(
          'Either stop $stop or start $start is greater than the '
          'length of this list $this | length: $length');
    }
    if (stop == 0){return <E>[];}

    //Create new list and add things from range into the list
    List<E> newList = [];
    for (int i in range(stop, start: start, step: step)) {
      newList.add(iterationList[i]);
    }
    return newList;
  }

  ///Returns a list of two sub-lists based off self:
  /// List 1: All items before specified index
  /// List 2: All items after specified index
  /// Negative `[-1]` is the same as the last list item and all negative numbers are likewise
  /// 0 leads to `[[],[this]]`
  /// whereas an index>this.length leads to [[this],[]]
  List<List<E>> splitBeforeIndex(int index) {
    while (index < 0) {
      index += length;
    }
    List<List<E>> newList = [[], []];
    for (int i in range(length)) {
      if (i >= index) {
        newList[1].add(this[i]);
      } else {
        newList[0].add(this[i]);
      }
    }
    return newList;
  }

  ///Similar to negative index in python `[-1]` will return the last thing in the list
  ///0 or over will return its `[]` operator
  E negativeIndex(int index) {
    while (index < 0) {
      index += length;
    }
    return this[index];
  }

  ///Setter for above
  void negativeIndexEquals(int index, E value) {
    while (index < 0) {
      index += length;
    }
    this[index] = value;
  }

  bool equals(Object other) => (identical(this, other) ||
      (DeepCollectionEquality().equals(this, other)));
}

extension MapUtils<K, V> on Map<K, V> {
  ///Checks if a map contains duplicate values in its values by using sets
  bool containsDuplicateValues() {
    Set<V> check = Set<V>.from(values);
    return check.length == values.length;
  }

  ///Returns a map with the keys and values swapped. If there are duplicate keys
  ///the function throws an argument error (So use with containsDuplicateValues()).
  Map<V, K> swap() {
    Map<V, K> newMap = {};
    Set<V> duplicateChecker = Set.from(values);
    if (duplicateChecker.length < length) {
      throw ArgumentError('There are duplicate'
          'values in the Maps values $values. Keys need to be unique therefore the swap could\'t happen');
    }
    forEach((key, value) {
      newMap[value] = key;
    });
    return newMap;
  }

  bool equals(Object other) => (identical(this, other) ||
      (DeepCollectionEquality().equals(this, other)));

  ///Works like [List.where], you put in a function that takes a MapEntry and returns a bool.
  ///This will return new Map where the above function is true.
  Map<K, V> where(BoolFunctionMap func) {
    Map<K, V> newMap = {};
    for (MapEntry entry in entries) {
      if (func(entry)) {
        newMap[entry.key] = entry.value;
      }
    }
    return newMap;
  }

  ///Sorts the Map based on the given function and RETURNS the sorted map. (Doesn't sort in place!)
  Map<K, V> sort(int Function(MapEntry<K, V>, MapEntry<K, V>) compare){
    List<MapEntry<K, V>> mapAsList = entries.toList();
    mapAsList.sort(compare);
    return Map.fromEntries(mapAsList);
  }
}

extension StringIter on String {
  /// Use to iterate over the individual characters
  /// of a String: `"Hello".iterate()` -> 'H' 'e' 'l' 'l' 'o'
  Iterable<String> iterate() sync* {
    for (var i = 0; i < length; i++) {
      yield this[i];
    }
  }
}

///Returns a reversed shallow copy of input list
List<T> reverse<T>(List<T> x) => List<T>.from(x.reversed);

///Flattens an infinitely nested list
Iterable<T> flatten<T>(Iterable<dynamic> iterable) sync* {
  for (final element in iterable) {
    if (element is Iterable<dynamic>) {
      yield* flatten<T>(element);
    } else {
      yield element as T;
    }
  }
}

///Similar to python range function iterates from start up to yet not including
///stop, incrementing by every step.
///Ex:
///for (int i in range(5, start: 1, step: 2)
///   {print(i);}
///>>> 1
///>>> 3
Iterable<int> range(int stop, {int? start, int? step}) sync* {
  step ??= 1;
  start ??= 0;
  if (step == 0) {
    throw ArgumentError('Step is 0, can\'t iterate');
  }
  if (stop == start) {
    throw ArgumentError('Start $start is == stop $stop');
  } else if (stop > start && step.isNegative) {
    throw ArgumentError('Start $start is >'
        ' than stop $stop, yet step $step is positive');
  } else if (stop < start && step.isPositive) {
    throw ArgumentError('Start $start is <'
        ' than stop $stop, yet step $step is negative');
  }

  for (int i = start; i < stop; i += step) {
    yield i;
  }
}

/// Rounds a num to double whereby the decimalPlaces represents the power of 10 you want to round to
/// such that:
/// ```
/// roundDecimal(31.141, -2) // => 0.0 (since its rounding between 100 & 0)
/// roundDecimal(31.141, -1) // => 30.0
/// roundDecimal(31.141, 0) // => 31.0
/// roundDecimal(31.141, 1) // => 31.1
/// roundDecimal(31.141, 2) // => 31.14
/// // etc...
/// ```
double roundDecimal(double number, int decimalPlaces) {
  double factor = pow(10, decimalPlaces).toDouble();
  return (number * factor).round() / factor;
}


/// List: List to combine elements of
/// Keyizer: Function to get key from an element of the list.
///
/// Valueizer: Function to get map's value from an element of a list relative
/// its key from keyizer.
///
/// Combinator: Function to combine derived values of two list elements whose
/// keyizer function returned the same key.
///
/// Example use case
/// ```dart
/// class Wallet{
///   owner string;
///   value int;
///   Wallet(this.owner, this.string)
/// }
///
/// List<Wallet> wallets = [
///   Wallet('A', 1),
///   Wallet('A', 1),
///   Wallet('A', 1),
///   Wallet('B', 1),
///   Wallet('B', 1),
///   Wallet('B', 1)
///   ];
///
/// // Generics wont show in code example but are (in order): Wallet, String, int
///
/// combineListValuesToMap<Wallet, String, int>(
///   wallets,
///   (Wallet elemToKey) => elemToKey.owner,
///   (Wallet elemToValue) => elemToValue.value,
///   (int existingSameKeyValue, int newSameKeyValue) => existingSameKeyValue + newSameKeyValue
/// )
/// // The above Returns {'A': 3, 'B': 3}
/// ```
Map<T1, T2> combineListValuesToMap<E, T1, T2>
    (List<E> list,
    T1 Function(E elemToKey) keyizer,
    T2 Function(E elemToValue) valueizer,
    T2 Function(T2 existingSameKeyValue, T2 newSameKeyValue) combinator){
  Map<T1, T2> result = {};
  for (E entry in list){
    T1 key = keyizer(entry);
    T2 value = valueizer(entry);
    if (result[key] == null){
      result[key] = value;
    }
    else{
      result[key] = combinator(result[key] as T2, value);
    }
  }
  return result;
}

///[Zip] is a list class with added functionality that pairs two equal matching
///iterables and combines the elements of the two iterables
///into a compound [ZipItem] that contains both of those elements. The added
///functionality is related to things therein such as:
///   swap all elements,
///   go from zip to map,
///   check if an element is contained within any of the pairs,
///   etc
///Like zip() in python
class Zip<I1, I2> extends DelegatingList<ZipItem<I1, I2>> {
  final List<ZipItem<I1, I2>> _base;

  Zip(this._base) : super(_base);

  void addItem(I1 item1, I2 item2) {
    _base.add(ZipItem(item1, item2));
  }

  Zip<I1, I2> extendItems(List<I1> a, List<I2> b) {
    return Zip.create(item1List + a, item2List + b);
  }

  List<I1> get item1List => _base.map<I1>((e) => e[0]).toList();

  List<I2> get item2List => _base.map<I2>((e) => e[1]).toList();

  factory Zip.create(List<I1> a, List<I2> b) {
    if (a.length == b.length) {
      List<ZipItem<I1, I2>> baseList = [];
      for (int i in range(a.length)) {
        baseList.add(ZipItem(a[i], b[i]));
      }
      return Zip(baseList);
    }
    throw ArgumentError('Length A != Length B\n${a.length} != ${b.length}');
  }

  ///Creates a Zip by pairing an even index with its next odd index
  ///The list must have an even length or you will encounter an [ArgumentError]
  ///ex:
  ///```
  /// [1,2,3,4,5,6] -->
  /// 1,2
  /// 3,4
  /// 5,6
  /// ```
  factory Zip.fromEvenListParity(List list){
    if (list.length % 2 != 0) {
      throw ArgumentError('List must be even current at ${list.length}');
    }
    List<ZipItem<I1, I2>> newBaseList = [];
    for (EnumListItem enumItem in enumerate(list)) {
      if (enumItem.i + 1 > list.length) {
        break;
      } else if (enumItem.i % 2 == 1) {
        continue;
      } else {
        newBaseList.add(ZipItem(enumItem.value, list[enumItem.index + 1]));
      }
    }
    return Zip(newBaseList);
  }

  ///Creates a Zip by splitting the list in half and zipping the entries on the
  ///first half of the list with the entries of the equivalent index on the second
  ///half of the list.
  ///The list must have an even length or you will encounter an [ArgumentError]
  ///ex:
  /// ```
  /// [1,2,3,4,5,6] -->
  /// ```
    /// 1,4
    /// 2,5
    /// 3,6
  factory Zip.fromEvenListSplit(List list){
    if (list.length % 2 != 0) {
      throw ArgumentError('List must be even current at ${list.length}');
    }
    List<ZipItem<I1, I2>> newBaseList = [];
    int halfOfList = list.length ~/ 2;
    for (int i in range(halfOfList)){
      newBaseList.add(ZipItem(list[i], list[i+halfOfList]));
    }
    return Zip(newBaseList);
  }

  factory Zip.castFromMap(Map map_) {
    List<ZipItem<I1, I2>> newBaseList = [];
    map_.forEach((key, value) {
      newBaseList.add(ZipItem(key, value));
    });
    return Zip(newBaseList);
  }

  List<ZipItem<I1, I2>> get base => _base;

  Zip<I2, I1> swapAll() {
    return Zip(_base.map((e) => e.swap()).toList());
  }

  /// Checks if item is any of the ZipItem entries, if the item is a
  /// ZipItem checks if it is in the base list itself.
  @override
  bool contains(Object? element) {
    if (element is ZipItem){
      return _base.contains(element);
    }
    for (ZipItem<I1, I2> item in _base) {
      if (item.item1 == element) {
        return true;
      }
      if (item.item2 == element) {
        return true;
      }
    }
    return false;
  }


  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zip && toString() == other.toString());

  @override
  int get hashCode => _base.hashCode;

  @override
  String toString() {
    // == is dependent on this
    return 'Zip{_base: $_base}';
  }

  Zip copyWith({List<ZipItem<I1, I2>>? base}) => Zip(base ?? List.from(_base));

  Map<I1, I2> toMap() {
    Map<I1, I2> m = {};
    for (ZipItem item in _base) {
      m[item[0]] = item[1];
    }
    return m;
  }

  Map<I2, I1> toMapSwitched() {
    Map<I2, I1> m = {};
    for (ZipItem item in _base) {
      m[item[1]] = item[0];
    }
    return m;
  }

  String toJson() => jsonEncode(_base.map((e) => e.toMap()).toList());
//</editor-fold>

}

///Class for a pair belonging to a zip with some functionality including:
/// swapping, ==, to & From type constructors, [] operations.
class ZipItem<I1, I2> {
  I1 item1;
  I2 item2;

  ZipItem(this.item1, this.item2);

  ///`[0]` retrieves first item `[1]` retrieves 2nd, negative numbers retrieve
  /// `[0]` if even or `[1]` if odd
  operator [](int index) {
    if (index == 0) {
      return item1;
    } else if (index == 1) {
      return item2;
    } else if (index < 0) {
      return this[(index % 2)];
    }
    throw RangeError('$index is out of range (only 1 and 2)');
  }

  operator []=(int index, newVal) {
    if (index == 0) {
      item1 = newVal;
    } else if (index == 1) {
      item2 = newVal;
    } else if (index < 0) {
      this[(index % 2)] = newVal;
    }
    throw RangeError('$index is out of range (only 1 and 2)');
  }

  ///Returns shallow copy with item1 & item2 swapped
  ZipItem<I2, I1> swap() {
    return ZipItem(item2, item1);
  }

  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZipItem &&
          item1.toString() == other.item1.toString() &&
          item2.toString() == other.item2.toString());

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;

  @override
  String toString() {
    // == is dependent on this
    return 'ZipItem{item1: $item1, item2: $item2}';
  }

  ZipItem<I1, I2> copyWith({
    I1? item1,
    I2? item2,
  })
      // currently broken because references are passed as deep copies
      =>
      ZipItem(
        item1 ?? this.item1,
        item2 ?? this.item2,
      );

  Map<String, dynamic> toMap() {
    return {
      'item1': item1,
      'item2': item2,
    };
  }

  List toList() => [item1, item2];

  ///Creates ZipItem from list of exactly 2
  factory ZipItem.fromList(List list) {
    if (list.length != 2) {
      throw ArgumentError('To create ZipItem list must be size two');
    }
    return ZipItem(list[0], list[1]);
  }

  factory ZipItem.fromMap(Map<String, dynamic> map) {
    return ZipItem(
      map['item1'] as I1,
      map['item2'] as I2,
    );
  }

//</editor-fold>
}

///Like python enumerate but with [EnumListItem] to iterate over an iterable with
///its index and value in a comfortable way.
Iterable<EnumListItem<T>> enumerate<T>(Iterable<T> iterable) sync* {
  int i = 0;
  for (T v in iterable) {
    yield EnumListItem<T>(i, v);
    i++;
  }
}

// Iterable<List<T>> iterateOverListPairs<T>(List<T> list) sync*{
//
// }

///Class to hold index and value of a list specifically with [enumerate].
class EnumListItem<T> {
  int index;
  T value;

  EnumListItem(this.index, this.value);

  int get i => index;

  T get v => value;
}

/// Logic operators for booleans
abstract class Logical {
  ///Takes bool and returns 1 if true 0 if false
  static int toBit(bool b) => b ? 1 : 0;

  static bool xand(bool a, bool b) {
    if ((a && b) || (!a && !b)) {
      return true;
    }
    return false;
  }

  static bool xor(bool a, bool b) {
    return !xand(a, b);
  }

  static bool not(bool a) => !a;

  static bool nor(bool a, bool b) {
    if (!a && !b) {
      return true;
    }
    return false;
  }

  ///Returns true if all entries are true, else false
  static bool all(List<bool?> args) {
    return !args.contains(false) && !args.contains(null) && args.isNotEmpty;
  }

  ///Returns true if any entry is true, else false
  static bool any(List<bool?> args) => args.contains(true);
}

/// Converts any val to boolean
///   [int] != 0
///   null => false
///   [bool] => [val]
///   tries: val.isNotEmpty
///   if has no getter isNotEmpty => true
bool toBool(val) {
  if (val is bool) {
    return val;
  }
  if (val == null) {
    return false;
  }
  if (val is num) {
    return val != 0;
  }
  // For strings|iterables
  // <editor-fold desc="Is not empty">
  try {
    return val.isNotEmpty;
  } on NoSuchMethodError {
    // Pass
  }
  // </editor-fold>
  return true;
}
