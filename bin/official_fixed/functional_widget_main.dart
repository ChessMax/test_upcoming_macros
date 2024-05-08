import 'package:test_upcoming_macros/official_fixed/functional_widget.dart';

@FunctionalWidget()
Widget buildGap(BuildContext context, double width) {
  return SizedBox(width: width);
}

void main() {
  final gap = BuildGap(15);
  print(gap);
  print(gap.build(BuildContext()));
  print((gap.build(BuildContext()) as SizedBox).width);
}
