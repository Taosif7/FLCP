/// A collection of static methods for printing CLI messages.
class CLIUtils {
  CLIUtils._();

  /// Set to true to enable verbose logging.
  static bool verbose = false;

  /// Prints an error message.
  static void printError(String message) {
    print('❌  $message');
  }

  /// Prints a warning message.
  static void printWarning(String message) {
    print('⚠️ $message');
  }

  /// Prints an informational message.
  static void printInfo(String message) {
    print('ℹ️ $message');
  }

  /// Prints a success message.
  static void printSuccess(String message) {
    print('✅  $message');
  }

  /// Prints a verbose message if verbose mode is enabled.
  static void printVerbose(String message) {
    if (verbose) print('🔍 $message');
  }
}
