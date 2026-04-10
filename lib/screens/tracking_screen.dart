import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../models/order_model.dart';

class TrackingScreen extends StatefulWidget {
  final OrderModel? order;
  const TrackingScreen({super.key, this.order});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const kGreen = Color(0xFF2E7D32);

  int get _currentStep {
    switch (widget.order?.trackingStatus ?? 'harvested') {
      case 'harvested':
        return 0;
      case 'packed':
        return 1;
      case 'in_transit':
        return 2;
      case 'out_for_delivery':
        return 3;
      case 'delivered':
        return 4;
      default:
        return 0;
    }
  }

  List<Map<String, dynamic>> _getTimelineSteps() {
    return [
      {
        'title': 'Order Placed',
        'description': 'Farmer received your order',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF2E7D32)
      },
      {
        'title': 'Packed',
        'description': 'Produce packed & ready for dispatch',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF1565C0)
      },
      {
        'title': 'In Transit',
        'description': 'On the way to your location',
        'icon': Icons.local_shipping_outlined,
        'color': const Color(0xFFE65100)
      },
      {
        'title': 'Out for Delivery',
        'description': 'Almost there! Arriving soon',
        'icon': Icons.delivery_dining_outlined,
        'color': const Color(0xFF6A1B9A)
      },
      {
        'title': 'Delivered',
        'description': 'Order delivered successfully',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF2E7D32)
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = widget.order;
    final timelineSteps = _getTimelineSteps();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Track Order',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (order != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: kGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order #${order.id}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        _statusChip(order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(order.productName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        '${order.quantity} ${order.unit} by ${order.farmerName}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${order.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        Text('Order placed: ${_formatDate(order.orderDate)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text('Order Status',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(timelineSteps.length, (index) {
              final step = timelineSteps[index];
              final isCompleted = index <= _currentStep;
              final isCurrent = index == _currentStep;
              final color = step['color'] as Color;
              final activeColor = isCompleted ? color : Colors.grey.shade400;

              return TimelineTile(
                alignment: TimelineAlign.manual,
                lineXY: 0.08,
                isFirst: index == 0,
                isLast: index == timelineSteps.length - 1,
                indicatorStyle: IndicatorStyle(
                  width: 42,
                  height: 42,
                  indicator: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? activeColor
                          : (isDark
                              ? Colors.grey.shade800
                              : Colors.grey.shade100),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              isCompleted ? activeColor : Colors.grey.shade300,
                          width: isCurrent ? 3 : 1.5),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                  color: activeColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2)
                            ]
                          : null,
                    ),
                    child: Icon(step['icon'] as IconData,
                        size: 20,
                        color:
                            isCompleted ? Colors.white : Colors.grey.shade400),
                  ),
                ),
                beforeLineStyle: LineStyle(
                    color:
                        index <= _currentStep ? kGreen : Colors.grey.shade300,
                    thickness: 2.5),
                afterLineStyle: LineStyle(
                    color: index < _currentStep ? kGreen : Colors.grey.shade300,
                    thickness: 2.5),
                endChild: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? activeColor.withOpacity(0.08)
                          : (isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade50),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: isCurrent
                              ? activeColor.withOpacity(0.3)
                              : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCompleted
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.black87)
                                        : Colors.grey.shade400,
                                  )),
                              const SizedBox(height: 3),
                              Text(step['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCompleted
                                        ? (isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600)
                                        : Colors.grey.shade400,
                                  )),
                            ],
                          ),
                        ),
                        if (isCompleted)
                          Icon(Icons.check_circle,
                              color: activeColor, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            if (order != null &&
                order.status != 'delivered' &&
                order.status != 'cancelled')
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated Delivery',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(_estimatedDelivery(order.orderDate),
                            style: TextStyle(
                                color: Colors.blue.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            if (order != null && order.status == 'delivered')
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: kGreen, size: 22),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Delivered!',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                                fontSize: 13)),
                        if (order.deliveredDate != null)
                          Text(_formatDate(order.deliveredDate!),
                              style: TextStyle(
                                  color: Colors.green.shade600, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'confirmed':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        label = 'Confirmed';
        break;
      case 'delivered':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = 'Delivered';
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = 'Cancelled';
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style:
              TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _estimatedDelivery(DateTime orderDate) {
    final est = orderDate.add(const Duration(days: 3));
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${est.day} ${months[est.month - 1]} ${est.year}';
  }
}
