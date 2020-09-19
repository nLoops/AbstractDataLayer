import 'package:abstract_data_layer/src/base/base_data_provider.dart';
import 'package:abstract_data_layer/src/base/base_firestore.dart';
import 'package:abstract_data_layer/src/sample.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

void main() {
  final collection = 'samples';
  FireStoreMock fireStoreMock;
  BaseDataProvider firestoreProvider;

  group('BaseFiresStore unit test', () {
    setUpAll(() {
      fireStoreMock = FireStoreMock();
      firestoreProvider =
          FireStoreImpl(collection: collection, firestore: fireStoreMock);
    });

    test('Verify insert & update & delete new sample works', () async {
      // Create fake collection
      CollectionReferenceMock sampleCollection = CollectionReferenceMock();
      // Create new sample object
      Sample sample1 = Sample(uid: '1', title: 'sample1', qty: 1);
      // Make mock return fake collection
      when(fireStoreMock.collection(collection)).thenReturn(sampleCollection);
      // Create fake doc
      DocumentReferenceMock sample1Doc = DocumentReferenceMock();
      // Make mock return fake doc
      when(sampleCollection.doc(sample1.uid)).thenReturn(sample1Doc);
      // Call insert new doc
      await firestoreProvider.insert(sample1.uid, sample1.toMap());
      // Test method result
      expect(sample1Doc.documentSnapshotMock.mockData['uid'], sample1.uid);
      expect(sample1Doc.documentSnapshotMock.mockData['title'], sample1.title);
      // Update operation
      sample1.title = 'sample2';
      // Call update new doc
      await firestoreProvider.update(sample1.uid, sample1.toMap());
      // Test method result
      expect(sample1Doc.documentSnapshotMock.mockData['title'], 'sample2');
      // Call delete existing doc
      await firestoreProvider.delete(sample1.uid);
      // Test method result
      expect(sample1Doc.documentSnapshotMock.mockData.isEmpty, true);
    });

    test('Verify getFutureList from firestore and return list with length',
        () async {
      // Create fake collection
      CollectionReferenceMock sampleCollection = CollectionReferenceMock();
      // Make mock return fake collection
      when(fireStoreMock.collection(collection)).thenReturn(sampleCollection);
      // Create fake query snapshots
      QuerySnapshotMock sampleSnapShots = QuerySnapshotMock();
      // Create List of Samples
      List<Sample> samples =
          List.generate(3, (i) => Sample(uid: '$i', title: 'Sample$i', qty: i));
      // When ask for docs return empty list
      when(sampleSnapShots.docs).thenReturn(samples
          .map((e) => QueryDocumentSnapshotMock(mockData: e.toMap()))
          .toList());
      // Make mock return fake snapshots
      when(sampleCollection.get())
          .thenAnswer((_) => Future.value(sampleSnapShots));
      // Call get method
      var data = await firestoreProvider.getFutureList();
      // Test method results
      expect(data.length, equals(3));
      // Map data into sample
      var sampleList = data.map((e) => Sample.fromMap(e)).toList();
      // Test results
      expect(sampleList[0].uid, '0');
    });

    test('Verify getStreamList from firestore and return list with length', () {
      // Create fake collection
      CollectionReferenceMock sampleCollection = CollectionReferenceMock();
      // Make mock return fake collection
      when(fireStoreMock.collection(collection)).thenReturn(sampleCollection);
      // Create fake query snapshots
      QuerySnapshotMock sampleSnapShots = QuerySnapshotMock();
      // Create List of Samples
      List<Sample> samples =
          List.generate(3, (i) => Sample(uid: '$i', title: 'Sample$i', qty: i));
      // When ask for docs return empty list
      when(sampleSnapShots.docs).thenReturn(samples
          .map((e) => QueryDocumentSnapshotMock(mockData: e.toMap()))
          .toList());
      // Make mock return fake snapshots
      when(sampleCollection.snapshots())
          .thenAnswer((_) => Stream.value(sampleSnapShots));
    });

    test('Verify getSingleFuture from firestore and return valid item', () {});

    test('Verify getSingleFuture from firestore and return null', () {});
  });
}
