import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_trail/src/app/app_dependencies.dart';

void main() {
  test('release build rejects a missing backend URL', () {
    expect(
      () => resolveBackendBaseUri(configuredValue: '', isRelease: true),
      throwsStateError,
    );
  });

  test('release build rejects an insecure backend URL', () {
    expect(
      () => resolveBackendBaseUri(
        configuredValue: 'http://api.receipt-trail.test',
        isRelease: true,
      ),
      throwsStateError,
    );
  });

  test('release build rejects a backend URL without a host', () {
    expect(
      () => resolveBackendBaseUri(
        configuredValue: 'https:///api',
        isRelease: true,
      ),
      throwsStateError,
    );
  });

  test('release build rejects reserved example domains', () {
    for (final host in ['example.com', 'api.example.org', 'example.net']) {
      expect(
        () => resolveBackendBaseUri(
          configuredValue: 'https://$host',
          isRelease: true,
        ),
        throwsStateError,
      );
    }
  });
}
