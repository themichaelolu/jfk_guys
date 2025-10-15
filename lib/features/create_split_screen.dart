import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/controllers/create_split_controller.dart';
import 'package:jfk_guys/features/add_participants_screen.dart';
import 'package:jfk_guys/utils/asyncvalue_ui.dart';
import 'package:jfk_guys/utils/custom_loader.dart';

class CreateSplitScreen extends ConsumerStatefulWidget {
  const CreateSplitScreen({super.key});

  @override
  ConsumerState<CreateSplitScreen> createState() => _CreateSplitScreenState();
}

class _CreateSplitScreenState extends ConsumerState<CreateSplitScreen>
    with SingleTickerProviderStateMixin {
  final _splitNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  // Shake animation controller
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _splitNameController.addListener(_onTextChanged);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 20,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController);
  }

  void _createSplit() async {
    final splitName = _splitNameController.text.trim();
    if (splitName.isEmpty) {
      _shakeController.forward(from: 0); // trigger shake
      return;
    }

    await ref
        .read(createSplitControllerProvider.notifier)
        .createSplit(
          name: splitName,
          afterFetched: (split) => Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => AddParticipantsScreen(
                splitName: split.name,
                splitId: split.id,
              ),
            ),
          ),
        );
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _splitNameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _splitNameController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  final List<String> _suggestions = [
    "Dinner with friends",
    "Beach Trip 2024",
    "Office Lunch",
    "Birthday Celebration",
    "Weekend Getaway",
    "Roommates Groceries",
    "Family Vacation",
    "Road Trip",
    "Friday Night Drinks",
    "Concert Tickets",
  ];

  Future<void> _getRandomSuggestion() async {
    final random = Random();
    final suggestion = _suggestions[random.nextInt(_suggestions.length)];

    // Animate typing suggestion
    _splitNameController.clear();
    for (int i = 0; i < suggestion.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      _splitNameController.text += suggestion[i];
      _splitNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _splitNameController.text.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      createSplitControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final isLoading = ref.watch(createSplitControllerProvider).isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        toolbarHeight: 100,
        title: const Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create New JFK",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Give your JFK a name", style: TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Split Details Section
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final offset = _shakeAnimation.value == 0
                      ? 0.0
                      : sin(_shakeAnimation.value) * 10;
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.darkTextSecondary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.group),
                          const SizedBox(width: 8),
                          const Text(
                            "JFK Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _splitNameController,
                        decoration: InputDecoration(
                          labelText: "JFK Name *",
                          hintText: "e.g., Dinner with friends",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.darkTextSecondary,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton.icon(
                          onPressed: _getRandomSuggestion,
                          icon: const Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                          ),
                          label: Text(
                            "Get Suggestion",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Create Split Button with animation
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          key: ValueKey(isLoading),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _createSplit,
                            style: Theme.of(context).elevatedButtonTheme.style,
                            child: isLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: customLoader(
                                      Theme.of(context).colorScheme.surface,
                                    ),
                                  )
                                : Text(
                                    "Create JFK",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                        ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Theme.of(context).dividerColor),
                      const SizedBox(height: 12),
                      const Text(
                        "Next, you'll add participants to this jfk",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pro Tips with fade & slide animation
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                curve: Curves.easeOut,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber),
                          const SizedBox(width: 8),
                          Text(
                            "Pro Tips",
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "• Use descriptive names like \"Beach Trip 2024\"\n"
                        "• Include the occasion or location\n"
                        "• You can always create multiple splits\n"
                        "• Each jfk tracks its own expenses separately",
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
