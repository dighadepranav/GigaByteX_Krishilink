import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackingTimeline extends StatelessWidget {
  final String currentStatus;
  final Map<String, dynamic>? priceBreakdown;

  const TrackingTimeline({
    super.key,
    required this.currentStatus,
    this.priceBreakdown,
  });

  final List<Map<String, dynamic>> _timelineSteps = const [
    {
      'status': 'harvested',
      'title': 'Harvested',
      'icon': Icons.agriculture,
      'description': 'Crops harvested from farm',
      'order': 0,
    },
    {
      'status': 'packed',
      'title': 'Packed',
      'icon': Icons.inventory,
      'description': 'Quality check & packing completed',
      'order': 1,
    },
    {
      'status': 'in_transit',
      'title': 'In Transit',
      'icon': Icons.local_shipping,
      'description': 'On the way to buyer',
      'order': 2,
    },
    {
      'status': 'out_for_delivery',
      'title': 'Out for Delivery',
      'icon': Icons.delivery_dining,
      'description': 'Nearby for final delivery',
      'order': 3,
    },
    {
      'status': 'delivered',
      'title': 'Delivered',
      'icon': Icons.check_circle,
      'description': 'Successfully delivered',
      'order': 4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentStepIndex = _getStepIndex(currentStatus);

    return Column(
      children: [
        ...List.generate(_timelineSteps.length, (index) {
          final step = _timelineSteps[index];
          final isCompleted = index <= currentStepIndex;
          final isCurrent = index == currentStepIndex;

          return TimelineTile(
            isFirst: index == 0,
            isLast: index == _timelineSteps.length - 1,
            beforeLineStyle: LineStyle(
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              thickness: 2,
            ),
            afterLineStyle: LineStyle(
              color: isCompleted && !isCurrent
                  ? Colors.green
                  : Colors.grey.shade300,
              thickness: 2,
            ),
            indicatorStyle: IndicatorStyle(
              width: 50,
              height: 50,
              padding: const EdgeInsets.all(8),
              indicator: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  border: isCurrent
                      ? Border.all(color: Colors.green, width: 3)
                      : null,
                ),
                child: Icon(
                  step['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            startChild: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step['title'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              isCompleted ? Colors.green.shade700 : Colors.grey,
                        ),
                      ),
                      if (isCompleted)
                        Icon(
                          isCurrent
                              ? Icons.hourglass_empty
                              : Icons.check_circle,
                          color: isCurrent ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['description'],
                    style: TextStyle(
                      color: isCompleted
                          ? Colors.grey.shade700
                          : Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                  if (priceBreakdown != null && step['status'] == currentStatus)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current Price: ₹${priceBreakdown!['currentPrice']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  int _getStepIndex(String status) {
    final step = _timelineSteps.firstWhere(
      (step) => step['status'] == status,
      orElse: () => _timelineSteps.first,
    );
    return step['order'];
  }
}
