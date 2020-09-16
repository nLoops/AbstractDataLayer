/// A base data type to be extended by all data objects
/// it helps in Firebase and Hive logic encapsulation
abstract class BaseDataType<T> {
  /// Returns instance of object upon passed map
  T getFromMap(Map data);

  /// Convert object to map
  Map<String, dynamic> convertToMap();
}
