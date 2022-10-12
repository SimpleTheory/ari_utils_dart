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
  group('Pythonic Enumeration', (){
    test('', (){

    });
  });
  //TODO
  group('Zip and ZipItem', (){
    test('', (){

    });
  });
}
