import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_usage_model.dart';
import '../models/document_model.dart';
import '../models/highlight_model.dart';
import '../models/user_settings_model.dart';
import 'hive_box.dart';

/// Centralized service to initialize Hive, register TypeAdapters, and open boxes.
class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register TypeAdapters if not already registered (prevents hot restart duplication)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DocumentModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(HighlightModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(UserSettingsModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(DailyUsageModelAdapter());
    }

    // Open boxes for use across the application
    await Hive.openBox<DocumentModel>(HiveBoxes.documents);
    await Hive.openBox<HighlightModel>(HiveBoxes.highlights);
    await Hive.openBox<UserSettingsModel>(HiveBoxes.userSettings);
    await Hive.openBox<DailyUsageModel>(HiveBoxes.dailyUsage);
  }
}
