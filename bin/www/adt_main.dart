import 'package:test_upcoming_macros/www/adt.dart';

// credit to eibaan

@ADT()
sealed class Expr {
  const Expr();

  Expr._lit(int value);
  Expr._add(Expr left, Expr right);

  int eval() => switch (this) {
        Lit(:final value) => value,
        Add(:final left, :final right) => left.eval() + right.eval(),
      };
}

void main() {
  print(Add(Lit(3), Lit(4)).eval());
}
