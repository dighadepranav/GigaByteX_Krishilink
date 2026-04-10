import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/locale_provider.dart';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  final Map<String, String> _labels = {
    'en': 'EN',
    'hi': 'HI',
    'mr': 'MR',
  };

  final Map<String, String> _fullNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'mr': 'मराठी',
  };

  Future<void> _changeLanguage(String langCode) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(langCode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to ${_fullNames[langCode]}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLang = localeProvider.locale.languageCode;

    return PopupMenuButton<String>(
      initialValue: currentLang,
      tooltip: 'Change language',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 20),
          const SizedBox(width: 4),
          Text(
            _labels[currentLang] ?? 'EN',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      onSelected: _changeLanguage,
      itemBuilder: (context) => _fullNames.entries.map((entry) {
        final isSelected = entry.key == currentLang;
        return PopupMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                entry.value,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.green : null,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
