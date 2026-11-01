import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/widgets.dart';
import 'data/local/hive_service.dart';
import 'data/repositories/document_repository.dart';
import 'presentation/library/bloc/library_bloc.dart';
import 'presentation/library/bloc/library_event.dart';
import 'presentation/library/screens/library_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const NotaApp());
}

/// The root application widget for Nota.
class NotaApp extends StatelessWidget {
  final DocumentRepository? documentRepository;

  const NotaApp({
    super.key,
    this.documentRepository,
  });

  @override
  Widget build(BuildContext context) {
    final repo = documentRepository ?? DocumentRepository();

    return RepositoryProvider<DocumentRepository>.value(
      value: repo,
      child: BlocProvider<LibraryBloc>(
        create: (context) => LibraryBloc(repository: repo)..add(const LoadLibraryEvent()),
        child: MaterialApp(
          title: 'Nota',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: LibraryScreen(
            onDocumentSelected: (doc) {
              // Reader navigation entry point (Milestone 3)
              NotaBottomSheet.show(
                context: context,
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: AppTypography.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Ready to open reader with ${doc.pageCount} pages. (Milestone 3)',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    NotaPillButton(
                      label: 'Close',
                      width: double.infinity,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              );
            },
            onSettingsPressed: () {
              // Settings entry point
              NotaBottomSheet.show(
                context: context,
                builder: (ctx) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Settings', style: AppTypography.headlineMedium),
                    const SizedBox(height: 12),
                    const Text(
                      'Gemini API key and daily quota settings.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    NotaPillButton(
                      label: 'Done',
                      width: double.infinity,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
