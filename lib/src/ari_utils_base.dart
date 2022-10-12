// TODO: Put public facing types in this file.
import 'dart:convert';
import 'package:ari_utils/ari_utils.dart';
import 'package:collection/collection.dart';

extension NumIsInt on num {bool get isInt => (this % 1) == 0;}
extension NumIsDouble on num {bool get isDouble => !isInt;}
extension NumIsPositive on num {bool get isPositive => this > 0;}

List<T> reverse<T>(List<T> x) => List<T>.from(x.reversed);
Iterable<int> range(int stop, {int? start, int? step}) sync* {
  step ??= 1;
  start ??= 0;
  for (int i = start; i < stop; i+=step){
    yield i;
  }
}
class EnumListItem<T>{
  int index;
  T value;
  EnumListItem(this.index, this.value);
  int get i => index;
  T get v => value;
}

class Zip<I1, I2> extends DelegatingList<ZipItem<I1 ,I2>> {
  final List<ZipItem<I1,I2>> _base;
  Zip(this._base) : super(_base);

  void addItem(I1 i1, I2 i2){
    _base.add(ZipItem(i1, i2));
  }
  Zip<I1, I2> extendItems(List<I1> a, List<I2> b){
    return Zip.create(item1List+a, item2List+b);
  }
  List<I1> get item1List => _base.map((e) => e[0]).toList() as List<I1>;
  List<I2> get item2List => _base.map((e) => e[1]).toList() as List<I2>;
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
    return 'Zip{' + ' _base: $_base,' + '}';
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
class ZipItem<I1, I2>{
  I1 item1;
  I2 item2;

  ZipItem(this.item1, this.item2);
  operator [](int index){
    if (index==0){return item1;}
    if (index==1){return item2;}
    throw RangeError('$index is out of range (only 1 and 2)');
  }
  operator []= (int index, newVal){
    if (index==0){item1=newVal;}
    if (index==1){item2=newVal;}
    throw RangeError('$index is out of range (only 1 and 2)');
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
    return 'ZipItem{ item1: $item1, item2: $item2,}';
  }

  ZipItem<I1, I2> copyWith({I1? item1, I2? item2,})
  =>ZipItem(item1 ?? this.item1, item2 ?? this.item2,);


  Map<String, dynamic> toMap() {
    return {
      'item1': item1,
      'item2': item2,
    };
  }

  factory ZipItem.fromMap(Map<String, dynamic> map) {
    return ZipItem(map['item1'] as I1, map['item2'] as I2,);
  }

//</editor-fold>
}
// class EnumMapItem<K, V>{
//   K key;
//   V value;
//   EnumMapItem(this.key, this.value);
//   K get k=>key;
//   V get v=>value;
// }
Iterable<EnumListItem<T>> enumerateList<T>(List<T> _list) sync* {
  int i = 0;
  for (T v in _list){
    yield EnumListItem<T>(i, v);
    i++;
  }
}
// Iterable<EnumMapItem<K, V>> enumerateMap<K, V>(Map<K, V> inputtedMap){
//   List<EnumMapItem<K, V>> uwu = [];
//   inputtedMap.forEach((key, value) {uwu.add(EnumMapItem(key, value));});
//   return uwu;
// }

