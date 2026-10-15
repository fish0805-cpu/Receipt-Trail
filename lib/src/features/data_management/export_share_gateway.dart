import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'receipt_export_service.dart';

enum ExportShareResult { completed, dismissed, unavailable }

abstract interface class ExportShareGateway {
  Future<ExportShareResult> share(
    ReceiptExportArchive archive, {
    required String title,
    required String subject,
  });
}

class SharePlusExportShareGateway implements ExportShareGateway {
  const SharePlusExportShareGateway();

  @override
  Future<ExportShareResult> share(
    ReceiptExportArchive archive, {
    required String title,
    required String subject,
  }) async {
    final directory = await getTemporaryDirectory();
    final file =
        File('${directory.path}${Platform.pathSeparator}${archive.fileName}');
    await file.writeAsBytes(archive.bytes, flush: true);
    try {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'application/zip')],
          title: title,
          subject: subject,
        ),
      );
      return switch (result.status) {
        ShareResultStatus.success => ExportShareResult.completed,
        ShareResultStatus.dismissed => ExportShareResult.dismissed,
        ShareResultStatus.unavailable => ExportShareResult.unavailable,
      };
    } finally {
      if (await file.exists()) await file.delete();
    }
  }
}
