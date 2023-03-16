// import 'package:ari_utils/ari_utils.dart';

import 'package:ari_utils/ari_utils.dart';

void main() {
  // TODO Implement example
  Zip<int, int> something = Zip.fromEvenListSplit(range(6).toList());
  Zip<int, int> something2 = Zip.fromEvenListParity(range(6).toList());
  print(something);
  print(something.slice(0));

}
