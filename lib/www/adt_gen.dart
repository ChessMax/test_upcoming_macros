augment library 'file:///C:/Projects/test_upcoming_macros/bin/adt_main.dart';

import 'dart:core' as prefix0;
import 'file:///C:/Projects/test_upcoming_macros/bin/adt_main.dart' as prefix1;

class Lit extends Expr {
  const Lit(this.value,);

  final prefix0.int value;
}

class Add extends Expr {
  const Add(this.left, this.right,);

  final prefix1.Expr left;
  final prefix1.Expr right;
}
