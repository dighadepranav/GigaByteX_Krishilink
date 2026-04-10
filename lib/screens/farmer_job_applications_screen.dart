import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> _demoApplications = [
    {
      'docId': '1',
      'workerName': 'Mahesh Jadhav',
      'workerPhone': '9876543210',
      'status': 'pending',
      'appliedAt': '2024-01-15'
    },
    {
      'docId': '2',
      'workerName': 'Sachin Shinde',
      'workerPhone': '9876543211',
      'status': 'pending',
      'appliedAt': '2024-01-14'
    },
    {
      'docId': '3',
      'workerName': 'Vilas More',
      'workerPhone': '9876543212',
      'status': 'accepted',
      'appliedAt': '2024-01-13'
    },
    {
      'docId': '4',
      'workerName': 'Dnyanesh Patil',
      'workerPhone': '9876543213',
      'status': 'rejected',
      'appliedAt': '2024-01-12'
    },
  ];

  @override
  void initState() {
    super.initState();
    _applications = List.from(_demoApplications);
  }

  Future<void> _updateStatus(String appDocId, String status) async {
    setState(() {
      final index = _applications.indexWhere((a) => a['docId'] == appDocId);
      if (index != -1) {
        _applications[index]['status'] = status;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Application $status'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating),
    );
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
              child: Text(
                  l10n?.translate('no_users_found') ?? 'No applications yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final app = _applications[index];
                final status = app['status'];
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
                            : (status == 'rejected'
                                ? Colors.red.shade100
                                : Colors.orange.shade100),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        (l10n?.translate(status) ?? status).toUpperCase(),
                        style: TextStyle(
                          color: status == 'accepted'
                              ? Colors.green.shade800
                              : (status == 'rejected'
                                  ? Colors.red.shade800
                                  : Colors.orange.shade800),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n?.translate('profile') ?? 'Applicant Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${l10n?.translate('your_name') ?? 'Name'}: ${app['workerName']}'),
            Text(
                '${l10n?.translate('phone') ?? 'Phone'}: ${app['workerPhone']}'),
            Text('Applied on: ${app['appliedAt']}'),
            const SizedBox(height: 12),
            if (status == 'pending') ...[
              const Text('Status:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(app['docId'], 'accepted');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                    child: Text(l10n?.translate('accept') ?? 'Accept'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(app['docId'], 'rejected');
                    },
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: Text(l10n?.translate('reject') ?? 'Reject'),
                  ),
                ],
              ),
            ],
            if (status != 'pending')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: status == 'accepted'
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Status: ${status.toUpperCase()}',
                  style: TextStyle(
                      color: status == 'accepted' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
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
