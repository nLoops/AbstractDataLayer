import 'dart:async';

import 'package:abstract_data_layer/src/base/base_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

abstract class BaseFireStore extends BaseDataProvider {
  /// Current firestore collection
  String get collection;

  /// Current firestore instance
  FirebaseFirestore get firestore;
}

/// A high level implementation of [BaseDataProvider]
class FireStoreImpl extends BaseFireStore {
  FireStoreImpl({@required String collection, FirebaseFirestore firestore}) {
    assert(collection != null);
    this._collection = collection;
    this._firestore = firestore ?? FirebaseFirestore.instance;
  }

  FirebaseFirestore _firestore;
  String _collection;

  @override
  String get collection => _collection;

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  Future<void> delete(String uid) =>
      _firestore.collection(collection).doc(uid).delete();

  @override
  Future<List<Map>> getFutureList() async {
    var snapshots = await _firestore.collection(collection).get();
    return snapshots.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<Map> getSingleFuture(String uid) async {
    var doc = await _firestore.collection(collection).doc(uid).get();
    return doc.data() == null ? null : doc.data();
  }

  @override
  Stream<List<Map>> getStreamList() => _firestore
      .collection(collection)
      .snapshots()
      .transform(StreamTransformer<QuerySnapshot, List<Map>>.fromHandlers(
          handleData: (QuerySnapshot snapshot, EventSink<List<Map>> sink) =>
              sink.add(snapshot.docs.map((e) => e.data()).toList())));

  @override
  Future<void> insert(String uid, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(uid).set(data);

  @override
  Future<void> update(String uid, Map<String, dynamic> data) =>
      _firestore.collection(collection).doc(uid).update(data);
}
