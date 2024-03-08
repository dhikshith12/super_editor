void main() {
  final inlineStylePattern = RegExp(r'(?<=\s|^)\*{1,3}[^*]+\*{1,3}(?=\s|$)');
  var candidate = "*****";
  if(inlineStylePattern.hasMatch(candidate)) {
    print("has match");
  } else {
    print("no match");
  }
}