import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/widgets/widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NotaApp());
}

/// The root application widget for Nota.
class NotaApp extends StatelessWidget {
  const NotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nota',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const FoundationPreviewScreen(),
    );
  }
}

/// A foundation screen verifying Milestone 1 setup, typography, and widgets.
class FoundationPreviewScreen extends StatelessWidget {
  const FoundationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nota'),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIcons.slidersHorizontal()),
            onPressed: () {
              NotaBottomSheet.show(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Settings Preview', style: AppTypography.headlineMedium),
                    const SizedBox(height: 12),
                    const Text(
                      'Offline bundled typography and flat Ink on Paper theme are active.',
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    NotaPillButton(
                      label: 'Close Sheet',
                      width: double.infinity,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Status & Badge
            const Row(
              children: [
                NotaBadge(label: 'Milestone 1 Active'),
                Spacer(),
                Text('OFFLINE READY', style: AppTypography.monoSmall),
              ],
            ),
            const SizedBox(height: 16),

            // Typography Test Section
            const NotaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Reading', style: AppTypography.headlineMedium),
                  SizedBox(height: 6),
                  Text(
                    'Inter font active for interface controls and primary navigation.',
                    style: AppTypography.bodyMedium,
                  ),
                  SizedBox(height: 12),
                  NotaHairlineDivider(),
                  SizedBox(height: 12),
                  Text(
                    '“The essence of active learning lies in continuous questioning and visual restructuring.”',
                    style: AppTypography.quote,
                  ),
                  SizedBox(height: 8),
                  Text('Newsreader Serif — Excerpt Preview', style: AppTypography.monoSmall),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Themed Progress Indicator (No ASCII)
            const Text('DAILY CAPACITY', style: AppTypography.monoSmall),
            const SizedBox(height: 8),
            const NotaLinearProgressBar(value: 0.35, height: 4),
            const SizedBox(height: 6),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('350 / 1000 requests', style: AppTypography.monoSmall),
                Text('RESETS AT 00:00', style: AppTypography.monoSmall),
              ],
            ),
            const SizedBox(height: 24),

            // Reusable Buttons Test
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                NotaPillButton(
                  label: 'Ask AI',
                  icon: PhosphorIcon(PhosphorIcons.sparkle(), size: 16, color: AppColors.paper),
                  onPressed: () {},
                ),
                NotaPillButton.outlined(
                  label: 'Generate Diagram',
                  icon: PhosphorIcon(PhosphorIcons.treeStructure(), size: 16, color: AppColors.ink),
                  onPressed: () {},
                ),
                NotaPillButton.subtle(
                  label: 'History',
                  icon: PhosphorIcon(PhosphorIcons.magnifyingGlass(), size: 16, color: AppColors.ink),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Empty State Component Preview
            NotaCard(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: NotaEmptyState(
                icon: PhosphorIconsRegular.filePdf,
                title: 'No Documents Imported',
                message: 'Tap below or drop a PDF to begin your generative study session.',
                actionLabel: 'Import PDF',
                onAction: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
