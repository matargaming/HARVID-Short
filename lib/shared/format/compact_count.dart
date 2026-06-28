String compactCount(int value) {
  if (value < 1000) {
    return value.toString();
  }

  if (value < 1000000) {
    return _compact(value / 1000, 'K');
  }

  return _compact(value / 1000000, 'M');
}

String _compact(double value, String suffix) {
  if (value >= 10 || value == value.truncateToDouble()) {
    return '${value.truncate()}$suffix';
  }

  return '${value.toStringAsFixed(1)}$suffix';
}
