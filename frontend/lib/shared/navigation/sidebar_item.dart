import 'package:flutter/material.dart';

class SidebarItem {
  final String label;
  final IconData icon;
  final String path;
  final String? badge;

  const SidebarItem({
    required this.label,
    required this.icon,
    required this.path,
    this.badge,
  });
}

class SidebarSection {
  final String title;
  final List<SidebarItem> items;

  const SidebarSection({
    required this.title,
    required this.items,
  });
}
