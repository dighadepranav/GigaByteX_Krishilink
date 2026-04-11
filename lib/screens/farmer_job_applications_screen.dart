import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/app_localizations.dart';

class FarmerJobApplicationsScreen extends StatefulWidget {
  final String jobDocId;

  const FarmerJobApplicationsScreen({super.key, required this.jobDocId});

  @override
  State<FarmerJobApplicationsScreen> createState() =>
      _FarmerJobApplicationsScreenState();
}

class _FarmerJobApplicationsScreenState
    extends State<FarmerJobApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [];

  @override
  void initState() {
    super.initState();
    FirestoreService().streamJobApplications(widget.jobDocId).listen((apps) {
      if (mounted) setState(() => _applications = apps);
    });
  }

  Future<void> _updateStatus(String appDocId, String status) async {
    final l10n = AppLocalizations.of(context);
    try {
      await FirestoreService().updateApplicationStatus(appDocId, status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n?.translate('status')}: $status'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${l10n?.translate('error_prefix') ?? 'Error'}: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.translate('job_requests') ?? 'Job Applications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _applications.isEmpty
          ? Center(
              child: Text(l10n?.translate('no_applications_yet') ??
                  'No applications yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final app = _applications[index];
                final status = app['status'] ?? 'pending';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(app['workerName'] ??
                        (l10n?.translate('worker') ?? 'Worker')),
                    subtitle: Text(app['workerPhone'] ?? ''),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: status == 'accepted'
                            ? Colors.green.shade100
                            : status == 'rejected'
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          l10n?.translate(status).toUpperCase() ??
                              status.toUpperCase(),
                          style: TextStyle(
                            color: status == 'accepted'
                                ? Colors.green.shade800
                                : status == 'rejected'
                                    ? Colors.red.shade800
                                    : Colors.orange.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          )),
                    ),
                    onTap: () => _showAppDetails(app, status),
                  ),
                );
              },
            ),
    );
  }

  void _showAppDetails(Map<String, dynamic> app, String status) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text(l10n?.translate('applicant_details') ?? 'Applicant Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n?.translate('your_name')}: ${app['workerName']}'),
            Text('${l10n?.translate('phone')}: ${app['workerPhone']}'),
            const SizedBox(height: 12),
            if (status == 'pending') ...[
              Text('${l10n?.translate('status')}:',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(app['docId'], 'accepted');
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(l10n?.translate('accept') ?? 'Accept',
                      style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _updateStatus(app['docId'], 'rejected');
                  },
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: Text(l10n?.translate('reject') ?? 'Reject'),
                ),
              ]),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.translate('close') ?? 'Close')),
        ],
      ),
    );
  }
}
