import 'dart:convert';
import 'package:ari_utils/ari_utils.dart';
import 'package:collection/collection.dart';

extension NumIs on num {
///Checks if num is int
  bool get isInt => (this % 1) == 0;
///Checks if num is decimal
  bool get isDouble => !isInt;
///Checks if a number > 0
  bool get isPositive => this > 0;}

extension PythonicListMethods<E> on List<E> {
  ///Returns a list slice from given list with all indeces contained within the
  ///given range. By default start=0, stop=list.length, step=1. Invalid inputs
  ///are met with ArgumentErrors.
  List<E> slice({int? stop, int start=0, int step=1}){
    //Defaults
    stop ??= length;

    //Clean Up Index (Negative and invalid start/stops)
    while(start<0){start+=length;}
    while(stop!<0){stop+=length;}
    if (start>length||stop>length)
    {throw ArgumentError('Either stop $stop or start $start is greater than the '
        'length of this list $this | length: $length');}

    //Create new list and add things from range into the list
    List<E> newList = [];
    for (int i in range(stop, start: start, step: step)){
      newList.add(this[i]);
    }
    return newList;
  }
  ///Same as func but implemented as a method
  List<List<E>> splitBeforeIndex(int index){
    while (index<0){index += length;}
    List<List<E>> newList = [[],[]];
    for (int i in range(length)){
      if (i>=index){newList[1].add(this[i]);}
      else {newList[0].add(this[i]);}
    }
    return newList;
  }
}

///Returns a reversed shallow copy of input list
List<T> reverse<T>(List<T> x) => List<T>.from(x.reversed);

///Returns a list of two sublists:
/// 1. All items before specified index
/// 2. All items after specified index
/// Negative [-1] is the same as the last list item and all negative numbers are likewise
/// 0 leads to [[],[og_list]]
/// whereas an index>oglist.length leads to [[og_list],[]]
List<List<E>> splitBeforeIndex<E>(List<E> og_list, int index){
  while (index<0){index += og_list.length;}
  List<List<E>> newList = [[],[]];
  for (int i in range(og_list.length)){
    if (i>=index){newList[1].add(og_list[i]);}
    else {newList[0].add(og_list[i]);}
  }
  return newList;
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
  if (step==0){throw ArgumentError('Step is 0, can\'t iterate');}
  if (stop==start){throw ArgumentError('Start $start is == stop $stop');}
  else if (stop>start && step.isNegative){throw ArgumentError('Start $start is >'
      ' than stop $stop, yet step $step is positive');}
  else if (stop<start && step.isPositive){throw ArgumentError('Start $start is <'
      ' than stop $stop, yet step $step is negative');}

  for (int i = start; i < stop; i+=step){
    yield i;
  }
}

///Zip is a list class with added functionality that pairs two equal matching
///lists, iterators, sets, etc and combines the elements of the two lists at
///into a compound ZipItem that contains both of those elements. The added
///functionality is related to things therein such as:
///   swap all elements,
///   go from zip to map,
///   check if an element is container
///   within any of the pairs,
///   etc
class Zip<I1, I2> extends DelegatingList<ZipItem<I1 ,I2>>{
  final List<ZipItem<I1,I2>> _base;
  Zip(this._base) : super(_base);

  void addItem(I1 item1, I2 item2){
    _base.add(ZipItem(item1, item2));
  }
  Zip<I1, I2> extendItems(List<I1> a, List<I2> b){
    return Zip.create(item1List+a, item2List+b);
  }

  List<I1> get item1List => _base.map<I1>((e) => e[0]).toList();
  List<I2> get item2List => _base.map<I2>((e) => e[1]).toList();

  factory Zip.create(List<I1> a, List<I2> b){
    if (a.length == b.length){
      List<ZipItem<I1, I2>> baseList = [];
      for (int i in range(a.length)){
        baseList.add(ZipItem(a[i], b[i]));
      }
      return Zip(baseList);
    }
    throw ArgumentError('Length A != Length B\n${a.length} != ${b.length}');
  }
  factory Zip.fromEvenList(List list){
    if (list.length % 2 != 0)
    {throw ArgumentError('List must be even current at ${list.length}');}
    List<ZipItem<I1, I2>> newBaseList = [];
    for (EnumListItem enumItem in enumerateList(list)){
      if (enumItem.i + 1 > list.length) {break;}
      else if(enumItem.i % 2 == 1){continue;}
      else{
        newBaseList.add(ZipItem(enumItem.value, list[enumItem.index+1]));
      }
    }
    return Zip(newBaseList);
  }
  factory Zip.fromMap(Map map_){
    List<ZipItem<I1, I2>> newBaseList = [];
    map_.forEach((key, value) {newBaseList.add(ZipItem(key, value));});
    return Zip(newBaseList);
  }
  Zip<I2, I1> swapAll(){
    return Zip(_base.map((e) => e.swap()).toList());
  }


  bool containsValue(Object? element) {
    for (ZipItem<I1, I2> item in _base){
      if (item.item1==element){return true;}
      if (item.item2==element){return true;}
    }
    return false;
  }

  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Zip &&
          runtimeType == other.runtimeType &&
          _base == other._base);

  @override
  int get hashCode => _base.hashCode;

  @override
  String toString() {
    return 'Zip{_base: $_base}';
  }

  Zip copyWith({List<ZipItem<I1, I2>>? base}) => Zip(base ?? _base,);

  Map<I1, I2> toMap() {
    Map<I1, I2> m = {};
    for (ZipItem item in _base){
      m[item[0]] = item[1];
    }
    return m;
  }

  Map<I2, I1> toMapSwitched() {
      Map<I2, I1> m = {};
      for (ZipItem item in _base){
        m[item[1]] = item[0];
      }
      return m;
  }

  String toJson()=> jsonEncode(_base.map((e) => e.toMap()).toList());
//</editor-fold>

}

///Data class for a pair belonging to a zip with some functionality including:
/// swapping, ==, to & From type constructors, [] operations.
class ZipItem<I1, I2>{
  I1 item1;
  I2 item2;

  ZipItem(this.item1, this.item2);
  ///[0] retrieves first item [1] retrieves 2nd, negative numbers retrieve
  /// [0] if even or [1] if odd
  operator [](int index){
    if (index==0){return item1;}
    else if (index==1){return item2;}
    else if(index<0){return this[(index % 2)];}
    throw RangeError('$index is out of range (only 1 and 2)');
  }
  operator []= (int index, newVal){
    if (index==0){item1=newVal;}
    else if (index==1){item2=newVal;}
    else if (index<0){this[(index % 2)]=newVal;}
    throw RangeError('$index is out of range (only 1 and 2)');
  }
  ///Returns shallow copy with item1 & item2 swapped
  ZipItem<I2, I1> swap(){
    return ZipItem(item2, item1);
  }

  //<editor-fold desc="Data Methods">

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ZipItem &&
          runtimeType == other.runtimeType &&
          item1 == other.item1 &&
          item2 == other.item2);

  @override
  int get hashCode => item1.hashCode ^ item2.hashCode;

  @override
  String toString() {
    return 'ZipItem{item1: $item1, item2: $item2}';
  }

  ZipItem<I1, I2> copyWith({I1? item1, I2? item2,})
  =>ZipItem(item1 ?? this.item1, item2 ?? this.item2,);


  Map<String, dynamic> toMap() {
    return {
      'item1': item1,
      'item2': item2,
    };
  }
  List toList()=> [item1, item2];
  ///Creates ZipItem from list of exactly 2
  factory ZipItem.fromList(List list){
    if (list.length != 2)
    {throw ArgumentError('To create ZipItem list must be size two');}
    return ZipItem(list[0], list[1]);
  }
  factory ZipItem.fromMap(Map<String, dynamic> map) {
    return ZipItem(map['item1'] as I1, map['item2'] as I2,);
  }

//</editor-fold>
}


Iterable<EnumListItem<T>> enumerateList<T>(List<T> list) sync* {
  int i = 0;
  for (T v in list){
    yield EnumListItem<T>(i, v);
    i++;
  }
}
class EnumListItem<T>{
  int index;
  T value;
  EnumListItem(this.index, this.value);
  int get i => index;
  T get v => value;
}

// class EnumMapItem<K, V>{
//   K key;
//   V value;
//   EnumMapItem(this.key, this.value);
//   K get k=>key;
//   V get v=>value;
// }
// Iterable<EnumMapItem<K, V>> enumerateMap<K, V>(Map<K, V> inputtedMap){
//   List<EnumMapItem<K, V>> uwu = [];
//   inputtedMap.forEach((key, value) {uwu.add(EnumMapItem(key, value));});
//   return uwu;
// }

