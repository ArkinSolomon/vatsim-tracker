/// Add "..." to the end of a string if its too long.
///
/// If the length of [str] is less than or equal to [len], str is returned
/// without change. Otherwise, str is cut to be exactly [len] characters long,
/// including the ellipsis at the end.
String setMaxLen(String str, int len) {
  if (str.length <= len) {
    return str;
  }

  str = str.substring(0, len - 3);
  return "$str...";
}
