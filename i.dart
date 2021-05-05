import 'dart:async';

Future<String> ticketText(String name, int value) async {
  String str = '$name has ${value} euros.';
  await Future.delayed(Duration(seconds: 1));
  return str;
}

main() async {
  var text = await ticketText("Tommy", 100);
  print(text);

  var li = [1, 4, 5, 6];
  li.where((n) => n % 2 == 0);
  // [4, 6]
  li.last;
  // 4
}
