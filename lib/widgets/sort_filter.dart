import 'package:flutter/material.dart';


class SortFilter extends StatelessWidget {
  final String currentSort;
  final void Function(String) onSortChanged;

  const SortFilter({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final newSort = currentSort == '최신순' ? '오래된순' : '최신순';
              onSortChanged(newSort);
            },
            child: Row(
              children: [
                const Icon(Icons.swap_vert, size: 16, color: Colors.deepPurple),
                const SizedBox(width: 6),
                Text(
                  currentSort,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
