import 'package:flutter/material.dart';
import '../models/job_model.dart';

class JobBoardScreen extends StatefulWidget {
  const JobBoardScreen({super.key});

  @override
  State<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends State<JobBoardScreen> {
  int _selectedIndex = 0;
  String _userName = 'Worker';
  String _userPhone = '9876543210';
  String _userLocation = 'Pune, Maharashtra';
  List<JobModel> _jobs = [];
  Set<String> _appliedJobIds = {};

  static const kPurple = Color(0xFF6A1B9A);
  static const kPurpleDark = Color(0xFF4A148C);
  static const kPurpleLight = Color(0xFF9C27B0);

  final List<JobModel> _demoJobs = [
    JobModel(
      id: 1,
      farmerId: 1,
      farmerName: 'Ramesh Patel',
      title: 'Harvesting Helper',
      description:
          'Need workers for tomato and chilli harvesting. Work for 6 hours daily.',
      location: 'Pune, Maharashtra',
      wage: 350,
      duration: '5 days',
      workersNeeded: 10,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    JobModel(
      id: 2,
      farmerId: 2,
      farmerName: 'Suresh Yadav',
      title: 'Field Worker',
      description: 'Looking for experienced farm workers for onion plantation.',
      location: 'Nashik, Maharashtra',
      wage: 400,
      duration: '7 days',
      workersNeeded: 5,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    JobModel(
      id: 3,
      farmerId: 3,
      farmerName: 'Anita Deshmukh',
      title: 'Organic Farming Assistant',
      description:
          'Need help with organic vegetable farming. Knowledge of organic methods preferred.',
      location: 'Satara, Maharashtra',
      wage: 450,
      duration: '10 days',
      workersNeeded: 3,
      status: 'open',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _jobs = List.from(_demoJobs);
  }

  Future<void> _applyForJob(String jobDocId) async {
    setState(() {
      _appliedJobIds.add(jobDocId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Rural Job Board',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: kPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildJobsBody(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: kPurple,
        unselectedItemColor: Colors.grey.shade500,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.work_rounded), label: 'Jobs'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildJobsBody() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final appliedCount = _appliedJobIds.length;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [kPurple, kPurpleLight],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle),
                child: const Text('👷', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $_userName!',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text(_userPhone,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text('$appliedCount Applied',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ),
        Expanded(
          child: _jobs.isEmpty
              ? const Center(child: Text('No jobs available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    final applied = _appliedJobIds.contains(job.docId);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                        border: applied
                            ? Border.all(
                                color: Colors.purple.shade300, width: 1.5)
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(job.title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold))),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Text(job.formattedWage,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2E7D32),
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                _chip(Icons.person_rounded, job.farmerName,
                                    Colors.blue),
                                _chip(Icons.location_on_rounded, job.location,
                                    Colors.orange),
                                _chip(Icons.access_time_rounded, job.duration,
                                    kPurple),
                                _chip(Icons.group_rounded,
                                    '${job.workersNeeded} needed', Colors.teal),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(job.description,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey.shade600)),
                            const SizedBox(height: 14),
                            if (applied)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.green.shade300),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF2E7D32), size: 18),
                                    const SizedBox(width: 8),
                                    const Text('Application Submitted!',
                                        style: TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: () => _applyForJob(job.docId),
                                  icon:
                                      const Icon(Icons.send_rounded, size: 16),
                                  label: const Text('Apply Now',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kPurple,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildProfileTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final appliedCount = _appliedJobIds.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [kPurpleDark, kPurpleLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: kPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle),
                  child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text('👷', style: TextStyle(fontSize: 38))),
                ),
                const SizedBox(height: 12),
                Text(_userName,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 4),
                if (_userPhone.isNotEmpty)
                  Text(_userPhone,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(_userLocation,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Text('👷  Farm Worker',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _miniStat('${_jobs.length}', 'Available',
                      Icons.work_rounded, kPurple, cardColor)),
              const SizedBox(width: 10),
              Expanded(
                  child: _miniStat('$appliedCount', 'Applied',
                      Icons.check_circle_rounded, Colors.green, cardColor)),
              const SizedBox(width: 10),
              Expanded(
                  child: _miniStat('4.5 ⭐', 'Rating', Icons.star_rounded,
                      Colors.orange, cardColor)),
            ],
          ),
          const SizedBox(height: 20),
          _profileTile(
              Icons.work_rounded,
              'Browse Jobs',
              '${_jobs.length} available',
              kPurple,
              cardColor,
              () => setState(() => _selectedIndex = 0)),
          _profileTile(
              Icons.check_circle_rounded,
              'Applied Jobs',
              '$appliedCount applied',
              Colors.green,
              cardColor,
              () => setState(() => _selectedIndex = 0)),
          _profileTile(Icons.help_outline_rounded, 'Help & Support',
              'support@krishilink.com', Colors.teal, cardColor, () {}),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Logout',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(
      String val, String label, IconData icon, Color color, Color cardColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)
          ]),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 15)),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, String sub, Color color,
      Color cardColor, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)
          ]),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(sub,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        trailing:
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
      ),
    );
  }
}
