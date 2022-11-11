import 'package:ari_utils/src/ari_utils_base.dart';
import 'package:test/test.dart';

///TODO Write tests for:
///   All range cases
///   Every method of Zip and its cases
///   List enumeration

void main() {
  group('Misc', () {
    List<num> exampleList = [-1, 0, 1, 1.5];
    test('Reverse', () {
      expect(reverse(exampleList), equals([1.5, 1, 0, -1]));
    });
    test('Pythonic List Enumeration', (){
      List<String> a = ['a','b','c'];
      List b = [];
      for (EnumListItem<String> i in enumerateList(a)){
        b.add(i.i);
        b.add(i.v);
      }
      expect(b, equals([0,'a',1,'b',2,'c']));
    });
    test('Pythonic Range default', (){

    });
    test('Pythonic range start stop', (){

    });
    test('Pythonic range start stop step', (){

    });
    test('Pythonic range with comically large step', (){

    });
    test('Pythonic range but stop < start so error', (){

    });


    test('Num is Int', (){
      expect(exampleList[0].isInt, isTrue);
      expect(exampleList.negativeIndex(-1).isInt, isFalse);
    });
    test('Num is Float', (){
      expect(exampleList[0].isDouble, isFalse);
      expect(exampleList.negativeIndex(-1).isDouble, isTrue);
    });
    test('Num is positive', (){
      expect(0.isPositive, isFalse);
      expect(0.1.isPositive, isTrue);
    });
    test('dict swap', (){
      Map<int, String> a = {1: 'a', 2: 'b'};
      Map<String, int> b = {'a': 1, 'b': 2};
      expect(a.swap(), b);
    });
  });
  //TODO
  group('ZipItem', (){
    test('[]', (){

    });
    test('[]=', (){

    });
    test('[]= Error', (){

    });
    test('Swap', (){

    });
    test('==', (){
      print(ZipItem([1,2,3], ['a','b','c']) == ZipItem([1,2,3], ['a','b','c']));
      expect(ZipItem('a', 1), ZipItem('a', 1));
      expect(ZipItem([1,2,3], ['a','b','c']), equals(ZipItem([1,2,3], ['a','b','c'])));

    });
    test('== falsey', (){
      print(ZipItem([1,2,1], ['a','b','c']) == ZipItem([1,2,3], ['a','b','c']));
      expect(ZipItem('a', 2) == ZipItem('a', 1), isFalse);
      expect(ZipItem([1,3], ['a','b','c']) == ZipItem([1,2,3], ['a','b','c']), isFalse);

    });
    test('toString', (){

    });
    test('toList', (){

    });
    test('toList Failed', (){

    });
    test('toMap', (){

    });
    test('toString', (){

    });
  });
  //TODO
  group('Zip', (){
    test('', (){

    });
    test('', (){

    });
    test('', (){

    });
    test('==', (){
      List list_1 = [1,2,3,4,5];
      List list_2 = ['a','b','c','d','e'];
      expect(Zip.create(list_1, list_2), Zip.create(list_1, list_2));

    });
    test('', (){

    });
  });
}
