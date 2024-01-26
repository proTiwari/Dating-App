Map<String, dynamic> castMap(Map map) {
  return map.map((key, value) {
    if (value is Map) {
      return MapEntry(key as String, castMap(value));
    } else {
      return MapEntry(key as String, value);
    }
  });
}