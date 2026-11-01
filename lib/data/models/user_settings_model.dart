import 'package:hive/hive.dart';
part 'user_settings_model.g.dart';

@HiveType(typeId: 3)
class UserSettingsModel extends HiveObject {
  @HiveField(0)
  final String? geminiApiKey;

  @HiveField(1)
  final String defaultAnswerStyle;

  @HiveField(2)
  final String defaultAiModel;

  UserSettingsModel({
    this.geminiApiKey, 
    required this.defaultAnswerStyle, 
    this.defaultAiModel = 'gemini-2.5-flash-lite'
    });

    UserSettingsModel copyWith({
      String? geminiApiKey,
      String? defaultAnswerStyle,
      String? defaultAiModel,
    }) {
      return UserSettingsModel(
        geminiApiKey: geminiApiKey ?? this.geminiApiKey,
        defaultAnswerStyle: defaultAnswerStyle ?? this.defaultAnswerStyle,
        defaultAiModel: defaultAiModel ?? this.defaultAiModel,
      );
    }
}
