/// converts values of type int to double
/// intended to use while parsing json values where type will be dynamic
/// returns value of type double
intToDouble(dynamic val) {
  if (val.runtimeType == double) {
    return val;
  } else if (val.runtimeType == int) {
    return val.toDouble();
  } else if (val == null) {
    return null;
  } else {
    throw Exception("value is not of type 'int' or 'double' got type '${val.runtimeType}'");
  }
}

/// converts values of type double to int
/// intended to use while parsing json values where type will be dynamic
/// returns value of type int
doubleToInt(dynamic val) {
  if (val.runtimeType == int) {
    return val;
  } else if (val.runtimeType == double) {
    return val.round();
  } else if (val == null) {
    return null;
  } else {
    throw Exception("value is not of type 'int' or 'double' got type '${val.runtimeType}'");
  }
}