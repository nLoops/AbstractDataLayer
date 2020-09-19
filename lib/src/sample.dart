import 'package:abstract_data_layer/src/base/base_data_type.dart';

class Sample {
  String uid;
  String title;
  int qty;

  Sample({this.uid, this.title, this.qty});

  factory Sample.fromMap(Map<dynamic, dynamic> map) {
    return new Sample(
      uid: map['uid'] as String,
      title: map['title'] as String,
      qty: map['qty'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    // ignore: unnecessary_cast
    return {
      'uid': this.uid,
      'title': this.title,
      'qty': this.qty,
    } as Map<String, dynamic>;
  }
}
