import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

// Firebase Mocks
class FireStoreMock extends Mock implements FirebaseFirestore {}

class CollectionReferenceMock extends Mock implements CollectionReference {}

class QuerySnapshotMock extends Mock implements QuerySnapshot {}

class QueryDocumentSnapshotMock extends Mock implements QueryDocumentSnapshot {
  Map mockData = Map<String, dynamic>();

  QueryDocumentSnapshotMock({this.mockData});
  @override
  Map<String, dynamic> data() => mockData;
}

class QueryMock extends Mock implements Query {}

class DocumentSnapshotMock extends Mock implements DocumentSnapshot {
  DocumentSnapshotMock({this.mockData});

  Map mockData = Map<String, dynamic>();

  set setData(Map data) => this.mockData = data;

  @override
  Map<String, dynamic> data() => mockData;

  @override
  bool get exists => true;
}

class DocumentReferenceMock extends Mock implements DocumentReference {
  DocumentSnapshotMock documentSnapshotMock;

  DocumentReferenceMock({this.documentSnapshotMock});

  @override
  Future<DocumentSnapshot> get([GetOptions options]) =>
      Future<DocumentSnapshotMock>.value(documentSnapshotMock);

  @override
  Stream<DocumentSnapshot> snapshots({bool includeMetadataChanges = false}) {
    if (documentSnapshotMock != null) {
      return Stream.fromFuture(
          Future<DocumentSnapshotMock>.value(documentSnapshotMock));
    } else {
      return Stream.empty();
    }
  }

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions options]) {
    if (this.documentSnapshotMock == null)
      this.documentSnapshotMock = DocumentSnapshotMock();

    if (this.documentSnapshotMock.data() == null) {
      documentSnapshotMock.mockData = Map<String, dynamic>();
    }

    data.forEach((k, v) => documentSnapshotMock.mockData[k] = v);

    return null;
  }

  @override
  Future<void> update(Map<String, dynamic> data) {
    if (this.documentSnapshotMock == null)
      this.documentSnapshotMock = DocumentSnapshotMock();
    if (this.documentSnapshotMock.data == null) {
      documentSnapshotMock.mockData = Map<String, dynamic>();
    }
    data.forEach((k, v) {
      documentSnapshotMock.mockData[k] = v;
    });
    return null;
  }

  @override
  Future<void> delete() {
    documentSnapshotMock.mockData.clear();
    return null;
  }
}

// Hive Mocks
class HiveBoxMock extends Mock implements Box {
  HiveBoxMock(this.data);

  List<Map> data;

  @override
  Iterable get values => data;

  @override
  Future<void> put(key, value) => data[0][key] = value;

  @override
  Future<void> delete(key) => data[0].remove(key);
}

class StreamControllerMock extends Mock implements StreamController {}
