import 'package:abstract_data_layer/src/base/base_data_type.dart';
import 'package:abstract_data_layer/src/sample.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Test [BaseDataType] extends functions', () {
    BaseDataType sample = Sample(uid: '1', title: 'test', qty: 2);
    Sample fromMap = sample.getFromMap(sample.convertToMap());
    expect(fromMap.uid, equals('1'));
  });
}
