import 'dart:async';

import 'package:abstract_data_layer/src/base/base_hive.dart';
import 'package:abstract_data_layer/src/sample.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mocks.dart';

void main() {
  final key = 'samples';
  HiveBoxMock _box;
  BaseHive _hiveProvider;
  Sample _sample;

  group('Hive provider unit test', () {
    setUpAll(() {
      _box = HiveBoxMock([]);
      _hiveProvider = HiveImpl(key: key, box: _box);
      _sample = Sample(uid: '100', title: 'Ahmed', qty: 1);
    });

    test('Test insert new record', () async {
      await _hiveProvider.insert(_sample.uid, _sample.toMap());
      expect(_hiveProvider.isEmpty, false);
    });
  });
}
