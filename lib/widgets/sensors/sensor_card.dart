import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sensor_model.dart';
import 'risk_badge.dart';
import 'trend_icon.dart';

/// Card showing one sensor: ID, reading + trend, location, timestamp, AI insight.
///
/// All text styles are pulled from [Theme.of(context).textTheme] — font sizes,
/// weights, and colours are maintained entirely in [AppTheme], not here.
class SensorCard extends StatelessWidget {
  final SensorModel sensor;
  final VoidCallback? onEdit;

  const SensorCard({super.key, required this.sensor, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin:  const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Sensor ID  ·  Risk badge  ·  Edit icon ────────────
          Row(
            children: [
              Text(sensor.id, style: tt.titleSmall),
              const Spacer(),
              RiskBadge(level: sensor.riskLevel),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  size:  18,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── Row 2: Reading value  ·  Trend arrow ─────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                sensor.latestReading.displayValue,
                // headlineSmall gives us 18 px bold — prominent but not oversized
                style: tt.headlineSmall,
              ),
              const SizedBox(width: 6),
              TrendIcon(trend: sensor.latestReading.trend),
            ],
          ),
          const SizedBox(height: 4),

          // ── Location ──────────────────────────────────────────────────
          Text(sensor.location, style: tt.bodyMedium),
          const SizedBox(height: 2),

          // ── Last update timestamp ─────────────────────────────────────
          Text(_formatTimestamp(sensor.latestReading.timestamp), style: tt.bodySmall),
          const SizedBox(height: 8),

          // ── AI insight snippet ────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: AppColors.teal),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sensor.aiInsight,
                  style:    tt.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Human-friendly relative timestamp, e.g. "Update 5 min ago".
  String _formatTimestamp(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'Update just now';
    if (diff.inMinutes < 60) return 'Update ${diff.inMinutes} min ago';
    if (diff.inHours   < 24) return 'Update ${diff.inHours}h ago';
    return 'Update ${diff.inDays}d ago';
  }
}