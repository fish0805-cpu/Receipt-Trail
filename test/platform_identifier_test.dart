import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const applicationId = 'com.peiyu.receipttrail';

  test(
    'Android namespace, application id and Kotlin package are consistent',
    () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      final activity = File(
        'android/app/src/main/kotlin/com/peiyu/receipttrail/MainActivity.kt',
      );

      expect(gradle, contains('namespace = "$applicationId"'));
      expect(gradle, contains('applicationId = "$applicationId"'));
      expect(activity.existsSync(), isTrue);
      expect(activity.readAsStringSync(), contains('package $applicationId'));
      expect(
        Directory('android/app/src/main/kotlin/com/example').existsSync(),
        isFalse,
      );
    },
  );

  test('iOS app and test targets use the production bundle identifier', () {
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();

    expect(
      RegExp('PRODUCT_BUNDLE_IDENTIFIER = $applicationId;').allMatches(project),
      hasLength(3),
    );
    expect(
      RegExp('PRODUCT_BUNDLE_IDENTIFIER = $applicationId.RunnerTests;')
          .allMatches(project),
      hasLength(3),
    );
    expect(project, isNot(contains('com.example')));
  });

  test(
    'iOS permission prompts provide English and Traditional Chinese copy',
    () {
      final project = File('ios/Runner.xcodeproj/project.pbxproj')
          .readAsStringSync();
      final english = File('ios/Runner/en.lproj/InfoPlist.strings')
          .readAsStringSync();
      final chinese = File('ios/Runner/zh-Hant.lproj/InfoPlist.strings')
          .readAsStringSync();

      expect(project, contains('InfoPlist.strings in Resources'));
      expect(project, contains('zh-Hant'));
      for (final key in const <String>[
        'NSCameraUsageDescription',
        'NSPhotoLibraryUsageDescription',
      ]) {
        expect(english, contains(key));
        expect(chinese, contains(key));
      }
      expect(english, contains('uses the camera'));
      expect(chinese, contains('相機權限'));
    },
  );

  test('Android release requires private upload signing credentials', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final rootIgnore = File('.gitignore').readAsStringSync();
    final androidIgnore = File('android/.gitignore').readAsStringSync();

    expect(gradle, contains('create("release")'));
    expect(
      gradle,
      contains('signingConfig = signingConfigs.getByName("release")'),
    );
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(rootIgnore, contains('android/key.properties'));
    expect(rootIgnore, contains('android/*.jks'));
    expect(androidIgnore, contains('key.properties'));
    expect(androidIgnore, contains('**/*.jks'));
  });

  test('Android release ignores absent optional ML Kit OCR scripts', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final proguard = File('android/app/proguard-rules.pro');

    expect(
      gradle,
      contains('getDefaultProguardFile("proguard-android-optimize.txt")'),
    );
    expect(gradle, contains('"proguard-rules.pro"'));
    expect(proguard.existsSync(), isTrue);
    final rules = proguard.readAsStringSync();
    expect(
      rules,
      contains('-dontwarn com.google.mlkit.vision.text.devanagari.**'),
    );
    expect(
      rules,
      contains('-dontwarn com.google.mlkit.vision.text.japanese.**'),
    );
    expect(rules, contains('-dontwarn com.google.mlkit.vision.text.korean.**'));
  });
}
