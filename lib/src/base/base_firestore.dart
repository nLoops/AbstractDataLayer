import 'package:abstract_data_layer/src/base/base_data_provider.dart';
import 'package:abstract_data_layer/src/base/base_data_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class BaseFireStore<T extends BaseDataType>
    extends BaseDataProvider<T> {
  /// Current firestore collection
  String get collection;

  /// Current firestore instance
  FirebaseFirestore get firestore;
}

/// A high level implementation of [BaseDataProvider]
class FireStoreImpl<T extends BaseDataType> extends BaseFireStore<T> {
  FireStoreImpl({@required String collection}) {
    assert(collection != null);
    this._collection = collection;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _collection;

  @override
  String get collection => _collection;

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  Future<void> delete(String uid) =>
      _firestore.collection(collection).doc(uid).delete();

  @override
  Future<List<T>> getFutureList() async {
    var snapshots = await _firestore.collection(collection).get();
    return snapshots.docs
        .map((doc) => (T as BaseDataType).getFromMap(doc.data()))
        .toList();
  }

  @override
  Future<T> getSingleFuture(String uid) async {
    var doc = await _firestore.collection(collection).doc(uid).get();
    return doc.data() == null
        ? null
        : (T as BaseDataType).getFromMap(doc.data());
  }

  @override
  Stream<List<T>> getStreamList() {
    // TODO: implement getStreamList
    throw UnimplementedError();
  }

  @override
  Future<void> insert(String uid, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(uid).set(data);

  @override
  Future<void> update(String uid, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(uid).update(data);
}
