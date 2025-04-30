abstract class Helper {
  static List<num> parseIntList(dynamic text) {
    return text
        .toString()
        .replaceAll("[", "")
        .replaceAll("]", "")
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
  }
}
