import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../models/order_model.dart';
import '../utils/app_localizations.dart';

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

  List<Map<String, dynamic>> _getTimelineSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return [
      {
        'title': l10n?.translate('order_placed') ?? 'Order Placed',
        'description': l10n?.translate('farmer_received_order') ??
            'Farmer received your order',
        'icon': Icons.shopping_bag_outlined,
        'color': const Color(0xFF2E7D32),
      },
      {
        'title': l10n?.translate('packed') ?? 'Packed',
        'description': l10n?.translate('packed_desc') ??
            'Produce packed and ready for dispatch',
        'icon': Icons.inventory_2_outlined,
        'color': const Color(0xFF1565C0),
      },
      {
        'title': l10n?.translate('in_transit') ?? 'In Transit',
        'description':
            l10n?.translate('in_transit_desc') ?? 'On the way to your location',
        'icon': Icons.local_shipping_outlined,
        'color': const Color(0xFFE65100),
      },
      {
        'title': l10n?.translate('out_for_delivery') ?? 'Out for Delivery',
        'description': l10n?.translate('out_for_delivery_desc') ??
            'Almost there, arriving soon',
        'icon': Icons.delivery_dining_outlined,
        'color': const Color(0xFF6A1B9A),
      },
      {
        'title': l10n?.translate('delivered') ?? 'Delivered',
        'description':
            l10n?.translate('delivered_desc') ?? 'Order delivered successfully',
        'icon': Icons.check_circle_outline,
        'color': const Color(0xFF2E7D32),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final order = widget.order;
    final isCancelled = order?.status == 'cancelled';
    final isRejected = order?.status == 'rejected';
    final timelineSteps = _getTimelineSteps(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.translate('track_order') ?? 'Track Order',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary card
            if (order != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
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
                        Text('${l10n?.translate('order_id')} #${order.id}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        _statusChip(order.status, context),
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
                        '${order.quantity} ${order.unit} ${l10n?.translate('by')} ${order.farmerName}',
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
                        Text(
                            '${l10n?.translate('order_placed')}: ${_formatDate(order.orderDate)}',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),

            if (order == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                    l10n?.translate('track_order') ??
                        'Track your order status below',
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
              ),

            const SizedBox(height: 24),

            // Route and payment details card (including phones)
            if (order != null && !isCancelled && !isRejected)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color:
                          isDark ? Colors.grey.shade800 : Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Row(children: [
                      Icon(Icons.location_on,
                          color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n?.translate('from') ?? 'From'}: ${order.farmerLocation ?? (l10n?.translate('farmers_farm') ?? "Farmer's Farm")}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.location_city,
                          color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n?.translate('to') ?? 'To'}: ${order.deliveryAddress ?? (l10n?.translate('buyers_location') ?? "Buyer's Location")}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.payment,
                          color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n?.translate('payment') ?? 'Payment'}: ${order.paymentMethodLabel}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.phone, color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n?.translate('farmer') ?? 'Farmer'}: ${order.farmerPhone.isNotEmpty ? order.farmerPhone : (l10n?.translate('not_provided') ?? 'Not provided')}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Icon(Icons.phone, color: Colors.blue.shade600, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${l10n?.translate('buyer') ?? 'Buyer'}: ${order.buyerPhone.isNotEmpty ? order.buyerPhone : (l10n?.translate('not_provided') ?? 'Not provided')}',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            if (isCancelled || isRejected)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.cancel_rounded,
                        color: Colors.red.shade700, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      isCancelled
                          ? (l10n?.translate('order_cancelled') ??
                              'Order Cancelled')
                          : (l10n?.translate('order_rejected') ??
                              'Order Rejected'),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCancelled
                          ? (l10n?.translate('you_cancelled_order') ??
                              'You cancelled this order.')
                          : (l10n?.translate('farmer_rejected_order') ??
                              'The farmer rejected this order.'),
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Colors.red.shade600, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.red.shade300,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.red.shade700, width: 2),
                          ),
                          child: Icon(Icons.close,
                              color: Colors.red.shade700, size: 20),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: Colors.red.shade300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n?.translate('order_cancelled_on') ?? 'Order cancelled on'} ${_formatDate(DateTime.now())}',
                      style:
                          TextStyle(color: Colors.red.shade600, fontSize: 12),
                    ),
                  ],
                ),
              )
            else ...[
              Text(l10n?.translate('order_status') ?? 'Order Status',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87)),
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
                            color: isCompleted
                                ? activeColor
                                : Colors.grey.shade300,
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
                      child: Icon(
                        step['icon'] as IconData,
                        size: 20,
                        color:
                            isCompleted ? Colors.white : Colors.grey.shade400,
                      ),
                    ),
                  ),
                  beforeLineStyle: LineStyle(
                    color:
                        index <= _currentStep ? kGreen : Colors.grey.shade300,
                    thickness: 2.5,
                  ),
                  afterLineStyle: LineStyle(
                    color: index < _currentStep ? kGreen : Colors.grey.shade300,
                    thickness: 2.5,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
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
                                  : Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step['title'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isCompleted
                                        ? (isDark
                                            ? Colors.white
                                            : Colors.black87)
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  step['description'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCompleted
                                        ? (isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600)
                                        : Colors.grey.shade400,
                                  ),
                                ),
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
              if (order != null && order.status != 'delivered')
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.blue.shade200),
                  ),
                  child: Row(children: [
                    Icon(Icons.access_time_rounded,
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              l10n?.translate('estimated_delivery') ??
                                  'Estimated Delivery',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                  fontSize: 13)),
                          Text(_estimatedDelivery(order.orderDate),
                              style: TextStyle(
                                  color: Colors.blue.shade600, fontSize: 12)),
                        ]),
                  ]),
                ),
              if (order != null && order.status == 'delivered')
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Row(children: [
                    Icon(Icons.check_circle, color: kGreen, size: 22),
                    const SizedBox(width: 10),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n?.translate('delivered') ?? 'Delivered!',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                  fontSize: 13)),
                          if (order.deliveredDate != null)
                            Text(_formatDate(order.deliveredDate!),
                                style: TextStyle(
                                    color: Colors.green.shade600,
                                    fontSize: 12)),
                        ]),
                  ]),
                ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case 'confirmed':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        label = l10n?.translate('confirmed') ?? 'Confirmed';
        break;
      case 'delivered':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = l10n?.translate('delivered') ?? 'Delivered';
        break;
      case 'cancelled':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = l10n?.translate('cancelled') ?? 'Cancelled';
        break;
      case 'rejected':
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = l10n?.translate('rejected') ?? 'Rejected';
        break;
      default:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade800;
        label = l10n?.translate('pending') ?? 'Pending';
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
