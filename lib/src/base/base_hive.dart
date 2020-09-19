import 'dart:async';

import 'package:abstract_data_layer/src/base/base_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

abstract class BaseHive extends BaseDataProvider {
  /// Getter of current box for more operations, not covered here.
  Box get box;

  /// Getter to check if box values are EMPTY, to forceUpdate from REMOTE source.
  bool get isEmpty;

  /// Values of hive box.
  Iterable<dynamic> get values;

  /// Dispose method for [StreamController].
  void dispose();

  /// Clear box data
  Future<void> clear();
}

/// An implementation of [BaseHive] logic.
class HiveImpl extends BaseHive {
  HiveImpl({@required String key, Box box, StreamController streamController}) {
    assert(key != null);

    /// Current box key
    this._key = key;

    /// Stream controller holds box data
    this._controller = streamController ?? StreamController.broadcast();

    /// Current box
    this._box = box ?? init();
  }

  StreamController _controller;
  String _key;
  Box _box;

  @override
  bool get isEmpty => _box == null ? true : _box.isEmpty;

  @override
  Box get box => _box;

  @override
  Iterable get values => _box == null ? [] : _box.values;

  /// Init and open box with passed key.
  Future<void> init() async {
    _box = await Hive.openBox(_key);
  }

  @override
  Future<void> delete(String uid) async {
    if (_box == null) await init();
    return _box.delete(uid);
  }

  @override
  Future<void> insert(String uid, Map<String, dynamic> data) async {
    if (_box == null) await init();
    return _box.put(uid, data);
  }

  @override
  Future<void> update(String uid, Map<String, dynamic> data) async {
    if (_box == null) await init();
    return _box.put(uid, data);
  }

  @override
  Future<List<Map>> getFutureList() async {
    if (_box == null) await init();
    var list = <Map>[];
    return _box.values.map((e) => list.add(e)).toList();
  }

  @override
  Future<Map> getSingleFuture(String uid) async {
    if (_box == null) await init();
    return _box.get(uid, defaultValue: null);
  }

  @override
  Stream<List<Map>> getStreamList() {
    getFutureList().then((data) => _controller.add(data));
    return _controller.stream;
  }

  @override
  void dispose() {
    _controller?.close();
  }

  @override
  Future<void> clear() => _box.clear();
}
