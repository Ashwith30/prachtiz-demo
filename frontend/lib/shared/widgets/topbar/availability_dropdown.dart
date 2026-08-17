import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DoctorStatus {
  final String label;
  final Color color;
  final Color bgColor;

  const DoctorStatus({
    required this.label,
    required this.color,
    required this.bgColor,
  });
}

class AvailabilityDropdown extends StatefulWidget {
  final ValueChanged<String>? onStatusChanged;

  const AvailabilityDropdown({
    super.key,
    this.onStatusChanged,
  });

  @override
  State<AvailabilityDropdown> createState() => _AvailabilityDropdownState();
}

class _AvailabilityDropdownState extends State<AvailabilityDropdown> {
  String _currentStatus = "Available";
  final Map<String, DoctorStatus> _statuses = {
    "Available": const DoctorStatus(
        label: "Available",
        color: AppColors.secondary,
        bgColor: AppColors.successLight),
    "On-Call": const DoctorStatus(
        label: "On-Call", color: AppColors.info, bgColor: AppColors.infoLight),
    "Busy": const DoctorStatus(
        label: "Busy", color: AppColors.danger, bgColor: AppColors.dangerLight),
    "Offline": const DoctorStatus(
        label: "Offline", color: AppColors.gray400, bgColor: AppColors.gray100),
  };

  @override
  Widget build(BuildContext context) {
    DoctorStatus status = _statuses[_currentStatus] ?? _statuses["Available"]!;

    return PopupMenuButton<String>(
      tooltip: "Change practitioner status",
      onSelected: (String newStatus) {
        setState(() {
          _currentStatus = newStatus;
        });
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!(newStatus);
        }
      },
      offset: const Offset(0, 42),
      itemBuilder: (BuildContext context) {
        return _statuses.keys.map((String key) {
          DoctorStatus item = _statuses[key]!;
          return PopupMenuItem<String>(
            value: key,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration:
                      BoxDecoration(color: item.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Text(
                  item.label,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        height: 34, // Match topbar element sizes in Image 2
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F223D),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status.label,
              style: AppTypography.bodySemibold.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down,
                size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
