import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jfk_guys/domain/providers/theme_provider.dart';
import 'package:jfk_guys/domain/services/auth_service.dart';
import 'package:jfk_guys/features/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String currency = "NGN";

  final List<Map<String, String>> currencies = const [
    {"code": "NGN", "symbol": "₦", "name": "Nigerian Naira"},
    {"code": "USD", "symbol": "\$", "name": "US Dollar"},
    {"code": "EUR", "symbol": "€", "name": "Euro"},
    {"code": "GBP", "symbol": "£", "name": "British Pound"},
    {"code": "JPY", "symbol": "¥", "name": "Japanese Yen"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currency = prefs.getString('splitwise-currency') ?? "NGN";
    });
  }

  Future<void> _updateCurrency(String newCurrency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('splitwise-currency', newCurrency);
    setState(() => currency = newCurrency);

    final curr = currencies.firstWhere(
      (c) => c['code'] == newCurrency,
      orElse: () => currencies.first,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Currency changed to ${curr['name']}")),
    );
  }

  void _handleClearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Clear Data"),
        content: const Text(
          "Are you sure you want to clear all data? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Clear Data"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      () {};
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All data cleared successfully")),
      );
    }
  }

  final currentUser = FirebaseAuth.instance.currentUser;

  void _handleLogout() async {
    await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);
    final isDarkMode = themeModeAsync.value == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account
          const SizedBox(height: 16),

          // Appearance (Riverpod theme)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              color: Colors.transparent,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 15,
                children: [
                  ListTile(
                    leading: Icon(Icons.light_mode_outlined),
                    title: Text('Appearace'),
                  ),

                  SizedBox(height: 16),
                  SwitchListTile(
                    value: isDarkMode,
                    title: Text(
                      "Dark Mode",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "Switch between light and dark themes",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    onChanged: (_) => themeController.toggleTheme(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Currency
          // Card(
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //           "Currency",
          //           style: TextStyle(fontWeight: FontWeight.bold),
          //         ),
          //         const SizedBox(height: 12),
          //         DropdownButton<String>(
          //           value: currency,
          //           isExpanded: true,
          //           items: currencies.map((c) {
          //             return DropdownMenuItem(
          //               value: c['code'],
          //               child: Text(
          //                 "${c['symbol']} ${c['name']} (${c['code']})",
          //               ),
          //             );
          //           }).toList(),
          //           onChanged: (val) {
          //             if (val != null) _updateCurrency(val);
          //           },
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 16),

          // Data Management
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                spacing: 15,
                children: [
                  ListTile(
                    leading: Icon(CupertinoIcons.delete),
                    title: Text('Data Management'),
                  ),
                  ListTile(
                    title: Text(
                      "Clear All Data",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "This will permanently delete all your data",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(CupertinoIcons.delete, color: Colors.white),
                    onPressed: () {
                      _handleClearData;
                    },
                    style: Theme.of(context).elevatedButtonTheme.style
                        ?.copyWith(
                          minimumSize: WidgetStatePropertyAll(
                            Size(double.infinity, 45),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.red.shade900,
                          ),
                        ),
                    label: Text(
                      'Clear all Data',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          if (currentUser != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  spacing: 16,
                  children: [
                    ListTile(
                      leading: Icon(CupertinoIcons.person),
                      title: Text('Account Management'),
                    ),

                    if (currentUser!.isAnonymous) ...[
                      Divider(color: Theme.of(context).dividerColor),
                      ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        ),
                        title: Text(
                          'Sign In',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Sign in to access your jfk across multiple devices',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Icon(
                          CupertinoIcons.chevron_right_circle_fill,
                        ),
                      ),
                      Divider(color: Theme.of(context).dividerColor),
                    ],

                    ListTile(
                      title: Text(
                        'Sign out',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Sign out from your JFK Account',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),

                      trailing: IconButton(
                        icon: Icon(Icons.logout, color: Colors.red),
                        onPressed: _handleLogout,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
