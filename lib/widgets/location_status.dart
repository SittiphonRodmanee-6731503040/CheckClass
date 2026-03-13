import 'package:flutter/material.dart';

class LocationStatus extends StatelessWidget {
  final bool isLocationEnabled;
  final bool isWithinRange;
  final double? distance;
  final VoidCallback? onRetry;

  const LocationStatus({
    super.key,
    required this.isLocationEnabled,
    this.isWithinRange = false,
    this.distance,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _iconColor,
                  ),
                ),
                if (_subtitle != null)
                  Text(
                    _subtitle!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          if (onRetry != null && !isWithinRange)
            IconButton(icon: const Icon(Icons.refresh), onPressed: onRetry),
        ],
      ),
    );
  }

  Color get _backgroundColor {
    if (!isLocationEnabled) return Colors.red.shade50;
    if (isWithinRange) return Colors.green.shade50;
    return Colors.orange.shade50;
  }

  Color get _borderColor {
    if (!isLocationEnabled) return Colors.red.shade200;
    if (isWithinRange) return Colors.green.shade200;
    return Colors.orange.shade200;
  }

  Color get _iconColor {
    if (!isLocationEnabled) return Colors.red;
    if (isWithinRange) return Colors.green;
    return Colors.orange;
  }

  IconData get _icon {
    if (!isLocationEnabled) return Icons.location_off;
    if (isWithinRange) return Icons.location_on;
    return Icons.location_searching;
  }

  String get _title {
    if (!isLocationEnabled) return 'Location unavailable';
    if (isWithinRange) return 'Within classroom range';
    return 'Outside classroom range';
  }

  String? get _subtitle {
    if (!isLocationEnabled) return 'Please enable location services';
    if (distance != null) {
      return '${distance!.toStringAsFixed(0)}m from classroom';
    }
    return null;
  }
}
