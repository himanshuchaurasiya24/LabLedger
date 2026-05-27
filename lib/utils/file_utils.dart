import 'dart:io';
import 'package:open_file_plus/open_file_plus.dart';

class FileUtils {
  static Future<OpenResult> openFile(String filePath) async {
    if (Platform.isLinux) {
      try {
        final env = Map<String, String>.from(Platform.environment);
        
        // Remove snap/flatpak specific environment variables that might interfere 
        // with the system's default application (like LibreOffice)
        env.remove('LD_LIBRARY_PATH');
        env.remove('GTK_PATH');
        env.remove('GTK_PATH_64');
        env.remove('GIO_EXTRA_MODULES');
        
        final result = await Process.run(
          'xdg-open',
          [filePath],
          environment: env,
          includeParentEnvironment: false,
        );
        
        if (result.exitCode == 0) {
          return OpenResult(
            type: ResultType.done, 
            message: 'done',
          );
        } else {
          return OpenResult(
            type: ResultType.error,
            message: result.stderr.toString().isNotEmpty 
              ? result.stderr.toString() 
              : 'Failed to open file with xdg-open',
          );
        }
      } catch (e) {
        return OpenResult(
          type: ResultType.error,
          message: e.toString(),
        );
      }
    }
    
    // For other platforms, use the default plugin
    return await OpenFile.open(filePath);
  }
}
