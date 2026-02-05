import 'dart:io';
import 'dart:typed_data';

/// Utility functions for EPUB handling
class EpubUtils {
  /// Checks if a file is a valid EPUB
  static Future<bool> isValidEpub(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      return isValidEpubBytes(bytes);
    } catch (e) {
      return false;
    }
  }

  /// Checks if bytes represent a valid EPUB
  static bool isValidEpubBytes(Uint8List bytes) {
    if (bytes.length < 4) return false;

    // Check ZIP header (EPUB files are ZIP archives)
    // ZIP files start with PK\x03\x04
    if (bytes[0] == 0x50 &&
        bytes[1] == 0x4B &&
        bytes[2] == 0x03 &&
        bytes[3] == 0x04) {
      return true;
    }

    return false;
  }

  /// Gets the file size in a human-readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Gets the file extension from a path
  static String getFileExtension(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  /// Checks if a file has an EPUB extension
  static bool hasEpubExtension(String filePath) {
    final extension = getFileExtension(filePath);
    return extension == 'epub';
  }

  /// Sanitizes a filename for safe storage
  static String sanitizeFilename(String filename) {
    // Remove or replace invalid characters
    return filename
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
  }

  /// Generates a unique filename
  static String generateUniqueFilename(String baseName, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final sanitizedBase = sanitizeFilename(baseName);
    return '${sanitizedBase}_$timestamp.$extension';
  }

  /// Extracts the base filename without extension
  static String getBaseFilename(String filePath) {
    final fileName = filePath.split('/').last;
    final parts = fileName.split('.');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('.');
    }
    return fileName;
  }

  /// Gets the directory path from a file path
  static String getDirectoryPath(String filePath) {
    final parts = filePath.split('/');
    if (parts.length > 1) {
      parts.removeLast();
      return parts.join('/');
    }
    return '.';
  }

  /// Creates a directory if it doesn't exist
  static Future<void> ensureDirectoryExists(String directoryPath) async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Copies a file to a new location
  static Future<void> copyFile(
    String sourcePath,
    String destinationPath,
  ) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);

    // Ensure destination directory exists
    await ensureDirectoryExists(getDirectoryPath(destinationPath));

    await sourceFile.copy(destinationPath);
  }

  /// Moves a file to a new location
  static Future<void> moveFile(
    String sourcePath,
    String destinationPath,
  ) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);

    // Ensure destination directory exists
    await ensureDirectoryExists(getDirectoryPath(destinationPath));

    await sourceFile.rename(destinationPath);
  }

  /// Deletes a file if it exists
  static Future<void> deleteFileIfExists(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Gets file information
  static Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return {'exists': false, 'error': 'File does not exist'};
      }

      final stat = await file.stat();
      final bytes = await file.readAsBytes();

      return {
        'exists': true,
        'path': filePath,
        'name': file.path.split('/').last,
        'size': bytes.length,
        'sizeFormatted': formatFileSize(bytes.length),
        'extension': getFileExtension(filePath),
        'isEpub': isValidEpubBytes(bytes),
        'lastModified': stat.modified,
        'created': stat.changed,
      };
    } catch (e) {
      return {'exists': false, 'error': e.toString()};
    }
  }

  /// Validates EPUB metadata
  static Map<String, dynamic> validateEpubMetadata(
    Map<String, dynamic> metadata,
  ) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check required fields
    if (metadata['title'] == null ||
        metadata['title'].toString().trim().isEmpty) {
      errors.add('Title is required');
    }

    if (metadata['creator'] == null ||
        metadata['creator'].toString().trim().isEmpty) {
      warnings.add('Creator/Author is recommended');
    }

    if (metadata['language'] == null ||
        metadata['language'].toString().trim().isEmpty) {
      warnings.add('Language is recommended');
    }

    if (metadata['identifier'] == null ||
        metadata['identifier'].toString().trim().isEmpty) {
      warnings.add('Identifier is recommended');
    }

    // Check field lengths
    if (metadata['title'] != null &&
        metadata['title'].toString().length > 500) {
      warnings.add(
        'Title is very long (${metadata['title'].toString().length} characters)',
      );
    }

    if (metadata['description'] != null &&
        metadata['description'].toString().length > 2000) {
      warnings.add(
        'Description is very long (${metadata['description'].toString().length} characters)',
      );
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
      'warnings': warnings,
      'score': _calculateMetadataScore(metadata),
    };
  }

  /// Calculates a metadata quality score
  static int _calculateMetadataScore(Map<String, dynamic> metadata) {
    int score = 0;

    // Required fields
    if (metadata['title'] != null &&
        metadata['title'].toString().trim().isNotEmpty)
      score += 30;
    if (metadata['creator'] != null &&
        metadata['creator'].toString().trim().isNotEmpty)
      score += 20;
    if (metadata['language'] != null &&
        metadata['language'].toString().trim().isNotEmpty)
      score += 15;
    if (metadata['identifier'] != null &&
        metadata['identifier'].toString().trim().isNotEmpty)
      score += 15;

    // Optional fields
    if (metadata['publisher'] != null &&
        metadata['publisher'].toString().trim().isNotEmpty)
      score += 5;
    if (metadata['date'] != null) score += 5;
    if (metadata['description'] != null &&
        metadata['description'].toString().trim().isNotEmpty)
      score += 5;
    if (metadata['subjects'] != null &&
        metadata['subjects'] is List &&
        metadata['subjects'].isNotEmpty)
      score += 5;

    return score;
  }

  /// Formats a duration in a human-readable format
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Formats a date in a human-readable format
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks == 1 ? '' : 's'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    }
  }
}
