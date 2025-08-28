// widgets/monthly_growth_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:labledger/models/referral_and_bill_chart_model.dart';

class MonthlyGrowthWidget extends ConsumerWidget {
  final List<ChartData> data;
  final String selectedPeriod;

  const MonthlyGrowthWidget({
    super.key,
    required this.data,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalBills = _calculateTotal();
    final growthPercentage = _calculateGrowthPercentage();
    final breakdown = _calculateBreakdown();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDF2F8), // Light pink
            Color(0xFFFEF7FF), // Very light purple
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF3E8FF).withValues( alpha:0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with growth percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getPeriodTitle(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626), // Red color
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues( alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      growthPercentage >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${growthPercentage >= 0 ? '+' : ''}${growthPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Total Bills Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues( alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 24,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Bills',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    totalBills.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Breakdown Section
          const Text(
            'Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress bars for each category
          ...breakdown.entries.map((entry) => _buildProgressBar(
            entry.key,
            entry.value,
            totalBills,
          )),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int value, int total) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForCategory(label),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'ultrasound':
        return const Color(0xFFDC2626); // Red
      case 'pathology':
        return const Color(0xFFEA580C); // Orange-red
      case 'franchise lab':
        return const Color(0xFFCA8A04); // Yellow-orange
      case 'ecg':
        return const Color(0xFF9333EA); // Purple
      case 'x-ray':
        return const Color(0xFF7C3AED); // Violet
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _getPeriodTitle() {
    switch (selectedPeriod.toLowerCase()) {
      case 'this week':
        return 'Weekly Growth';
      case 'this month':
        return 'Monthly Growth';
      case 'this year':
        return 'Yearly Growth';
      case 'all time':
        return 'All Time Stats';
      default:
        return 'Monthly Growth';
    }
  }

  int _calculateTotal() {
    return data.fold<int>(0, (sum, item) => sum + item.total);
  }

  double _calculateGrowthPercentage() {
    // This is a simplified calculation
    // You might want to implement a more sophisticated growth calculation
    // based on comparing with previous period data
    if (data.isEmpty) return 0.0;
    
    // For demo purposes, using a random-ish calculation
    final total = _calculateTotal();
    final avgPerDay = data.isNotEmpty ? total / data.length : 0;
    
    // Simulate growth percentage based on some logic
    // In real implementation, you'd compare with previous period
    return (avgPerDay - 1.5) * 10; // Example calculation
  }

  Map<String, int> _calculateBreakdown() {
    if (data.isEmpty) {
      return {
        'ECG': 0,
        'Franchise Lab': 0,
        'Pathology': 0,
        'Ultrasound': 0,
        'X-Ray': 0,
      };
    }

    // Calculate totals for each category
    final breakdown = {
      'ECG': data.fold<int>(0, (sum, item) => sum + item.ecg),
      'Franchise Lab': data.fold<int>(0, (sum, item) => sum + item.franchiseLab),
      'Pathology': data.fold<int>(0, (sum, item) => sum + item.pathology),
      'Ultrasound': data.fold<int>(0, (sum, item) => sum + item.ultrasound),
      'X-Ray': data.fold<int>(0, (sum, item) => sum + item.xray),
    };

    return breakdown;
  }
}

// Alternative compact version for smaller spaces
class CompactMonthlyGrowthWidget extends StatelessWidget {
  final List<ChartData> data;
  final String selectedPeriod;

  const CompactMonthlyGrowthWidget({
    super.key,
    required this.data,
    required this.selectedPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final totalBills = data.fold<int>(0, (sum, item) => sum + item.total);
    final breakdown = _calculateBreakdown();
    final topCategories = _getTopCategories(breakdown, 3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDF2F8),
            Color(0xFFFEF7FF),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Growth',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFDC2626),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withValues( alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            totalBills.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
          const Text(
            'Total Bills',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          ...topCategories.entries.take(3).map((entry) => 
            _buildCompactProgressBar(entry.key, entry.value, totalBills)
          ),
        ],
      ),
    );
  }

  Widget _buildCompactProgressBar(String label, int value, int total) {
    final percentage = total > 0 ? (value / total) : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateBreakdown() {
    if (data.isEmpty) {
      return {
        'ECG': 0,
        'Franchise Lab': 0,
        'Pathology': 0,
        'Ultrasound': 0,
        'X-Ray': 0,
      };
    }

    return {
      'ECG': data.fold<int>(0, (sum, item) => sum + item.ecg),
      'Franchise Lab': data.fold<int>(0, (sum, item) => sum + item.franchiseLab),
      'Pathology': data.fold<int>(0, (sum, item) => sum + item.pathology),
      'Ultrasound': data.fold<int>(0, (sum, item) => sum + item.ultrasound),
      'X-Ray': data.fold<int>(0, (sum, item) => sum + item.xray),
    };
  }

  Map<String, int> _getTopCategories(Map<String, int> breakdown, int count) {
    var entries = breakdown.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(entries.take(count));
  }
}