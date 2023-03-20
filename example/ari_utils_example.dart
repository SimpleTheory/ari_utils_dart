// import 'package:ari_utils/ari_utils.dart';

import 'package:ari_utils/ari_utils.dart';

void main() {
  // TODO Implement example
  Zip<int, int> something = Zip.fromEvenListSplit(range(6).toList());
  Zip<int, int> something2 = Zip.fromEvenListParity(range(6).toList());
  print(something.base.slice(stop: -2));
  print(something);

}
