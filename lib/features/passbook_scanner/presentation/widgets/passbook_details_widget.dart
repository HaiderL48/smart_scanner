import 'package:flutter/material.dart';
import 'package:smart_scanner/features/passbook_scanner/domain/passbook_details.dart';

class PassbookDetailsWidget extends StatelessWidget {
  final BankDetails? bankDetails;
  const PassbookDetailsWidget({super.key, required this.bankDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3460), Color(0xFF533483)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Passbook Details',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            label: 'Account Number',
            value: bankDetails!.accountNumber ?? 'Not found',
            icon: Icons.credit_card,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildDetailRow(
            label: 'Account Holder Name',
            value: bankDetails!.accountHolderName ?? 'Not found',
            icon: Icons.calendar_today,
          ),
          const Divider(color: Colors.white24, height: 24),
          _buildDetailRow(
            label: 'Account IFSC Code',
            value: bankDetails!.ifscCode ?? 'Not found',
            icon: Icons.person,
          ),
        ],
      ),
    );
  }
}

Widget _buildDetailRow({
  required String label,
  required String value,
  required IconData icon,
}) {
  return Row(
    children: [
      Icon(icon, color: Colors.white54, size: 20),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    ],
  );
}
