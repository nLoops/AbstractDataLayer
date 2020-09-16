import 'package:abstract_data_layer/src/base/base_data_type.dart';

/// Sample object to test [BaseDataType]
class Sample extends BaseDataType {
  String uid;
  String title;
  int qty;

  Sample({this.uid, this.title, this.qty});

  factory Sample._fromMap(Map<dynamic, dynamic> map) {
    return new Sample(
      uid: map['uid'] as String,
      title: map['title'] as String,
      qty: map['qty'] as int,
    );
  }

  Map<String, dynamic> _toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'title': this.title,
      'qty': this.qty,
    } as Map<String, dynamic>;
  }

  @override
  Map<String, dynamic> convertToMap() => _toMap();

  @override
  getFromMap(Map<dynamic, dynamic> data) => Sample._fromMap(data);
}
