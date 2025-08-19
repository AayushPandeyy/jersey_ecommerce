import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jersey_ecommerce/enum/OrderStatus.dart';
import 'package:jersey_ecommerce/enum/PaymentStatus.dart';
import 'package:jersey_ecommerce/models/CartOrderModel.dart';

class AdminOrderDetailsPage extends StatefulWidget {
  final CartOrderModel order;

  const AdminOrderDetailsPage({Key? key, required this.order})
    : super(key: key);

  @override
  State<AdminOrderDetailsPage> createState() => _AdminOrderDetailsPageState();
}

class _AdminOrderDetailsPageState extends State<AdminOrderDetailsPage> {
  late CartOrderModel order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  // Firestore functions
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).update(
        {'status': newStatus.toString()},
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('Orders').doc(orderId).update(
        {'paymentStatus': newStatus.toString()},
      );
    } catch (e) {
      throw Exception('Failed to update order payment status: $e');
    }
  }

  // Method to update order status
  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await updateOrderStatus(order.id!, newStatus);
      setState(() {
        order = order.copyWith(status: newStatus);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${newStatus.toString().split('.').last}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Method to update payment status
  Future<void> _updatePaymentStatus(PaymentStatus newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await updateOrderPaymentStatus(order.id!, newStatus);
      setState(() {
        order = order.copyWith(paymentStatus: newStatus);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment status updated to ${newStatus.toString().split('.').last}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment status: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _isUpdating ? null : () => _showStatusUpdateDialog(order),
            icon: _isUpdating 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.edit),
            tooltip: 'Update Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Jersey Information Card
            _buildJerseyInfoCard(),
            const SizedBox(height: 16),

            // Customer Information Card
            _buildCustomerInfoCard(),
            const SizedBox(height: 16),

            // Payment Information Card
            _buildPaymentInfoCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _isUpdating ? null : () => _showStatusUpdateDialog(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(order.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 14,
                          color: _getStatusColor(order.status),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Order ID: ${order.id ?? 'N/A'}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Order Date: ${_formatDate(order.orderDate)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Total Items: ${order.items.length}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJerseyInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Items (${order.items.length})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildJerseyItemCard(item)),
            const Divider(height: 20),
            _buildDetailRow(
              'Total Amount',
              '\$${order.totalAmount.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJerseyItemCard(CartOrderItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Jersey Name', item.jersey.jerseyTitle),
          _buildDetailRow('Price per Item', '\$${item.itemPrice.toStringAsFixed(2)}'),
          _buildDetailRow('Quantity', '${item.quantity}'),
          _buildDetailRow('Size', item.selectedSize),
          _buildDetailRow(
            'Item Total',
            '\$${item.totalPrice.toStringAsFixed(2)}',
            valueColor: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', order.fullname),
            _buildDetailRow('Phone', order.phoneNumber),
            _buildDetailRow('Address', order.address),
            _buildDetailRow('City', order.city),
            _buildDetailRow('Postal Code', order.postalCode),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: _isUpdating ? null : () => _showPaymentStatusUpdateDialog(order),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: (order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.paymentStatus.toString().split('.').last,
                          style: TextStyle(
                            color: order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Method',
              order.paymentMethod.toString().split('.').last.toUpperCase(),
            ),
            _buildDetailRow(
              'Amount',
              '\$${order.totalAmount.toStringAsFixed(2)}',
            ),
            _buildDetailRow(
              'Status', 
              order.paymentStatus.toString().split('.').last.toUpperCase(), 
              valueColor: order.paymentStatus.toString().split('.').last == "PAID" ? Colors.green : Colors.red
            ),
            if (order.khaltiTransactionId != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Khalti Transaction ID', order.khaltiTransactionId!),
            ],
            if (order.khaltiRefId != null) ...[
              const SizedBox(height: 4),
              _buildDetailRow('Khalti Ref ID', order.khaltiRefId!),
            ],
            if (order.paymentDate != null) ...[
              const SizedBox(height: 4),
              _buildDetailRow('Payment Date', _formatDate(order.paymentDate!)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? (isTotal ? Colors.black : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Order Status update dialog
  void _showStatusUpdateDialog(CartOrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${order.status.toString().split('.').last.toUpperCase()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select new status:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...OrderStatus.values.map(
                (status) => _buildStatusOption(order, status),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Payment Status update dialog
  void _showPaymentStatusUpdateDialog(CartOrderModel order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Update Payment Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status: ${order.paymentStatus.toString().split('.').last.toUpperCase()}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select new status:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ...PaymentStatus.values.map(
                (status) => _buildPaymentStatusOption(order, status),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Status option widget
  Widget _buildStatusOption(CartOrderModel order, OrderStatus status) {
    final isCurrentStatus = order.status == status;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isCurrentStatus
            ? Border.all(color: _getStatusColor(status), width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          status.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
            color: isCurrentStatus ? _getStatusColor(status) : null,
          ),
        ),
        trailing: isCurrentStatus
            ? Icon(Icons.check_circle, color: _getStatusColor(status))
            : null,
        onTap: isCurrentStatus ? null : () {
          Navigator.of(context).pop();
          _updateOrderStatus(status);
        },
        enabled: !isCurrentStatus,
      ),
    );
  }

  // Payment Status option widget
  Widget _buildPaymentStatusOption(CartOrderModel order, PaymentStatus status) {
    final isCurrentStatus = order.paymentStatus == status;
    final statusColor = status.toString().split('.').last == "PAID" ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isCurrentStatus
            ? Border.all(color: statusColor, width: 2)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          status.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            fontWeight: isCurrentStatus ? FontWeight.bold : FontWeight.normal,
            color: isCurrentStatus ? statusColor : null,
          ),
        ),
        trailing: isCurrentStatus
            ? Icon(Icons.check_circle, color: statusColor)
            : null,
        onTap: isCurrentStatus ? null : () {
          Navigator.of(context).pop();
          _updatePaymentStatus(status);
        },
        enabled: !isCurrentStatus,
      ),
    );
  }

  // Helper method to get status color
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.PENDING:
        return Colors.orange;
      case OrderStatus.SHIPPED:
        return Colors.blue;
      case OrderStatus.DELIVERED:
        return Colors.green;
      case OrderStatus.CANCELLED:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}