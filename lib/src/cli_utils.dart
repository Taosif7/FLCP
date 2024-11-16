class CLIUtils {
  CLIUtils._();

  static bool verbose = false;

  static void printError(String message) {
    print('❌  $message');
  }

  static void printWarning(String message) {
    print('⚠️ $message');
  }

  static void printInfo(String message) {
    print('ℹ️ $message');
  }

  static void printSuccess(String message) {
    print('✅  $message');
  }

  static void printVerbose(String message) {
    if (verbose) print('🔍 $message');
  }
}
