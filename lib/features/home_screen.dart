import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/models/split_model.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:jfk_guys/features/create_split_screen.dart';
import 'package:jfk_guys/features/expense_list_screen.dart';
import 'package:jfk_guys/features/settings_screen.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splitsAsync = ref.watch(splitsStreamProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: [
          // AppBar section
          SliverAppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'JFK',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'JFK with your guys, no stress',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(CupertinoIcons.settings_solid),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Start New Split Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: CustomPaint(
                painter: _DashedRectPainter(
                  color: AppColors.darkTextSecondary,
                  strokeWidth: 1.2,
                  dashWidth: 6,
                  gap: 6,
                  radius: 8,
                ),
                child: Container(
                  height: 130,
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.darkTextPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => const CreateSplitScreen(),
                          ),
                        );
                      },
                      style: Theme.of(context).elevatedButtonTheme.style,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 15,
                        children: [
                          Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          Text(
                            'Start New JFK',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Splits Section
          splitsAsync.when(
            data: (splits) {
              if (splits.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 20,
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: const Icon(Icons.add, size: 30),
                          ),
                          Text(
                            'No JFK yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Create your first JFK to start tracking shared expenses with friends',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) =>
                                      const CreateSplitScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            label: Text(
                              'Create First JFK',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(250, 50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverList.separated(
                itemCount: splits.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(CupertinoIcons.clock),
                          const SizedBox(width: 8),
                          Text(
                            'Recent splits',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                  final split = splits[index - 1];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => ExpenseListScreen(
                            splitId: split.id,
                            splitName: split.name,
                          ),
                        ),
                      ),
                      child: SplitListWidget(splitModel: split),
                    ),
                  );
                },
              );
            },
            error: (e, _) =>
                SliverFillRemaining(child: Center(child: Text("Error: $e"))),
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: _ShimmerCard(),
                ),
                childCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class SplitListWidget extends ConsumerWidget {
  const SplitListWidget({super.key, this.splitModel});

  final SplitModel? splitModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesProvider(splitModel?.id ?? '')).value;
    final summary = ref.watch(summaryProvider(splitModel?.id ?? '')).value;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final txt = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // scale UI based on available width (clamped)
        final baseWidth = 360.0;
        final scale = (constraints.maxWidth / baseWidth).clamp(0.85, 1.25);

        final borderRadius = BorderRadius.circular(12 * scale);
        final padding = EdgeInsets.all(16 * scale);
        final titleStyle = txt.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          fontSize: (16 * scale),
        );
        final metaStyle = txt.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontSize: (12 * scale),
        );
        final amountStyle = txt.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          fontSize: (14 * scale),
        );

        return Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: theme.cardColor, // use theme card color
            borderRadius: borderRadius,
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.05),
                blurRadius: 6 * scale,
                offset: Offset(0, 3 * scale),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      splitModel?.name ?? '',
                      style: titleStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceVariant,
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                    child: Text(
                      'NGN ${currencyFormat.format(summary?.totalExpenses ?? 0)}',
                      style: amountStyle,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8 * scale),

              // People + Expenses
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16 * scale,
                    color: cs.onSurfaceVariant,
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    "${splitModel?.participants.length ?? 0} people",
                    style: metaStyle,
                  ),
                  SizedBox(width: 10 * scale),
                  Container(
                    height: 4 * scale,
                    width: 4 * scale,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Text(
                    '${expenses?.length.toString() ?? ''} ${expenses?.length == 1 ? 'expense' : 'expenses'}',
                    style: metaStyle,
                  ),
                ],
              ),

              SizedBox(height: 6 * scale),

              // Created Date
              Text(
                splitModel?.createdAt != null
                    ? splitModel!.createdAt
                          .toLocal()
                          .toString()
                          .split(' ')
                          .first
                    : '',
                style: metaStyle,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Painter that draws a dashed (dotted) rounded rectangle around the child.
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gap;
  final double radius;

  _DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.dashWidth = 5.0,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extract = metric.extractPath(
          distance,
          next.clamp(0.0, metric.length),
        );
        canvas.drawPath(extract, paint);
        distance += dashWidth + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}

final currencyFormat = NumberFormat("#,###", "en_US");
