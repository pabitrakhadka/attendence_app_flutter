//Upper case
String toUppercase(String input) {
  return input.toUpperCase();
}

//CapialFirst Letter
String Capitalize(String input) {
  return input.isNotEmpty ? input[0].toUpperCase() + input.substring(1) : input;
}

String capitalizeEachWord(String input) {
  List<String> words = input.split(' ');
  List<String> capitalizedWords = words.map((word) {
    return word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '';
  }).toList();
  return capitalizedWords.join(' ');
}
