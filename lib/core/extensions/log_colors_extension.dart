extension ColorfulLogs on String? {
  String get logBlack => ' \x1B[30m$this\x1B[0m';
  String get logRed => '\x1B[31m$this\x1B[0m';
  String get logGreen => '\x1B[32m$this\x1B[0m';
  String get logYellow => '\x1B[33m$this\x1B[0m';
  String get logBlue => '\x1B[34m$this\x1B[0m';
  String get logMagenta => '\x1B[35m$this\x1B[0m';
  String get logCyan => '\x1B[36m$this\x1B[0m';
  String get logWhite => '\x1B[37m$this\x1B[0m';
}
