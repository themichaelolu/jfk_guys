import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/constants/app_colors.dart';
import 'package:jfk_guys/domain/controllers/add_participant_controller.dart';
import 'package:jfk_guys/domain/controllers/create_split_controller.dart';
import 'package:jfk_guys/domain/providers/firestore_service_provider.dart';
import 'package:jfk_guys/features/add_expense_screen.dart';
import 'package:jfk_guys/utils/custom_loader.dart';
import '../../domain/models/participant.dart';
import 'package:uuid/uuid.dart';

class AddParticipantsScreen extends ConsumerStatefulWidget {
  final String splitId;
  final String splitName;

  const AddParticipantsScreen({
    super.key,
    required this.splitId,
    required this.splitName,
  });

  @override
  ConsumerState<AddParticipantsScreen> createState() =>
      _AddParticipantsScreenState();
}

class _AddParticipantsScreenState extends ConsumerState<AddParticipantsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final uuid = const Uuid();

  Future<void> _addParticipant() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a name")));
      return;
    }

    final participants =
        ref.read(participantsProvider(widget.splitId)).value ?? [];
    if (participants.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Participant already added")),
      );
      return;
    }

    final newParticipant = Participant(id: uuid.v4(), name: name);
    await ref
        .read(firestoreServiceProvider)
        .addParticipant(widget.splitId, newParticipant);

    _controller.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$name added!")));
  }

  Future<void> _removeParticipant(String participantId) async {
    await ref
        .read(firestoreServiceProvider)
        .removeParticipant(widget.splitId, participantId);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Participant removed")));
  }

  @override
  Widget build(BuildContext context) {
    final participantsAsync = ref.watch(participantsProvider(widget.splitId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 7,
          children: [
            Text("Add Participants"),
            Text(
              widget.splitName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      body: participantsAsync.when(
        data: (participants) {
          final canContinue = participants.length >= 2;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Add Participant Form
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Add Participant",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: "Name",
                            hintText: 'Enter name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: Theme.of(context).elevatedButtonTheme.style
                              ?.copyWith(
                                minimumSize: const WidgetStatePropertyAll(
                                  Size(double.infinity, 40),
                                ),
                              ),
                          onPressed: _addParticipant,
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          label:
                              ref
                                  .watch(addParticipantControllerProvider)
                                  .isLoading
                              ? customLoader(
                                  Theme.of(context).colorScheme.surface,
                                )
                              : Text(
                                  "Add Participant",
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Participants List
              Text(
                "Participants (${participants.length})",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (participants.isEmpty)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: 1,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: const [
                          Icon(
                            Icons.person_add_alt,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text("No participants added yet"),
                          Text(
                            "Add at least 2 people to continue",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: participants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final p = entry.value;

                    return TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              p.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                          ),
                          title: Text(p.name),
                          subtitle: index == 0
                              ? const Text(
                                  "First participant",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeParticipant(p.id),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16),

              // Continue Button with animation
              AnimatedScale(
                scale: canContinue ? 1 : 0.95,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: ElevatedButton.icon(
                  iconAlignment: IconAlignment.end,
                  onPressed: canContinue
                      ? () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => AddExpenseScreen(
                                splitId: widget.splitId,
                                friends: participants,
                                splitName: widget.splitName,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  label: Text(
                    "Continue to Expenses",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),

                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    disabledBackgroundColor: Theme.of(
                      context,
                    ).colorScheme.surface,

                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              if (!canContinue)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "Add at least 2 participants to continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}
