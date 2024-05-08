augment library 'file:///C:/Projects/test_upcoming_macros/bin/multicast_main.dart';

import 'package:test_upcoming_macros/multicast.dart' as prefix0;
import 'file:///C:/Projects/test_upcoming_macros/bin/multicast_main.dart' as prefix1;
import 'dart:core' as prefix2;

@prefix0.MulticastMethod()
class DelegateMulticast implements Delegate {
  final List<prefix1.Delegate> _delegates;

  DelegateMulticast(this._delegates);
}
augment class DelegateMulticast {
  void onPress(prefix2.int a,) {
    for (final delegate in _delegates) {
      delegate.onPress(
        a,
      );
    }
  }

  void onSave(prefix2.String path, prefix2.double content,) {
    for (final delegate in _delegates) {
      delegate.onSave(
        path, content,
      );
    }
  }
}