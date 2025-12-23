import 'package:flutter/material.dart';

class KpiSection extends StatelessWidget {
  final List kpis;

  const KpiSection({super.key, required this.kpis});

  @override
  Widget build(BuildContext context) {
    // ✅ FILTER ONLY COLLECTION & DELIVERY
    final filteredKpis =
        kpis.where((kpi) {
          final title = kpi['title']?.toString().toLowerCase() ?? '';

          return title.contains('collection') ||
              title.contains('deliver'); // ✅ matches delivery + deliveries
        }).toList();

    if (filteredKpis.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredKpis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final kpi = filteredKpis[i];
          final color = _themeColor(kpi['theme']);

          return GestureDetector(
            onTap: () {
              // TODO: Navigate using kpi['target']
            },
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.15), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconForTitle(kpi['title']),
                          size: 18,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          kpi['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    kpi['count'].toString(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Today',
                    style: TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔽 helpers unchanged

  // 🎨 THEME COLOR MAPPER
  Color _themeColor(String? theme) {
    switch (theme) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // 🧩 ICON MAPPER (SAFE DEFAULT)
  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('collection')) return Icons.inventory_2;
    if (t.contains('deliver')) return Icons.local_shipping;
    if (t.contains('task')) return Icons.task_alt;
    return Icons.analytics;
  }
}
