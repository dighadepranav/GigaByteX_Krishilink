import 'package:flutter/material.dart';
import '../models/job_model.dart';

class FarmerJobApplicationsScreen extends StatefulWidget {
  final String jobDocId;
  const FarmerJobApplicationsScreen({super.key, required this.jobDocId});

  @override
  State<FarmerJobApplicationsScreen> createState() =>
      _FarmerJobApplicationsScreenState();
}

class _FarmerJobApplicationsScreenState
    extends State<FarmerJobApplicationsScreen> {
  List<Map<String, dynamic>> _applications = [
    {
      'docId': '1',
      'workerName': 'Mahesh Jadhav',
      'workerPhone': '9876543210',
      'status': 'pending'
    },
    {
      'docId': '2',
      'workerName': 'Sachin Shinde',
      'workerPhone': '9876543211',
      'status': 'pending'
    },
    {
      'docId': '3',
      'workerName': 'Vilas More',
      'workerPhone': '9876543212',
      'status': 'accepted'
    },
  ];

  Future<void> _updateStatus(String appDocId, String status) async {
    setState(() {
      final index = _applications.indexWhere((a) => a['docId'] == appDocId);
      if (index != -1) {
        _applications[index]['status'] = status;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status: $status'), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Applications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _applications.isEmpty
          ? const Center(child: Text('No applications yet'))
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
                    title: Text(app['workerName']),
                    subtitle: Text(app['workerPhone']),
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
                        status.toUpperCase(),
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Applicant Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${app['workerName']}'),
            Text('Phone: ${app['workerPhone']}'),
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Accept',
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(app['docId'], 'rejected');
                    },
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}
