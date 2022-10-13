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
      expect(exampleList[-1].isInt, isFalse);
    });
    test('Num is Float', (){
      expect(exampleList[0].isDouble, isFalse);
      expect(exampleList[-1].isDouble, isTrue);
    });
    test('Num is positive', (){
      expect(0.isPositive, isFalse);
      expect(0.1.isPositive, isTrue);
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
    test('', (){

    });
    test('', (){

    });
  });
}
