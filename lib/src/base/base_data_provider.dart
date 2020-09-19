import 'dart:async';
import 'package:abstract_data_layer/src/base/base_data_type.dart';

/// Base CRUD operations to be implemented by [BaseFireStore] and [BaseHive]
abstract class BaseDataProvider<T extends BaseDataType> {
  /// Returns a future list of object
  Future<List<Map>> getFutureList();

  /// Returns stream of list of object
  Stream<List<Map>> getStreamList();

  /// Query single object by passing uid
  Future<Map> getSingleFuture(String uid);

  /// Insert new record
  Future<void> insert(String uid, Map<String, dynamic> data);

  /// Update existing record
  Future<void> update(String uid, Map<String, dynamic> data);

  /// Delete existing record
  Future<void> delete(String uid);
}
