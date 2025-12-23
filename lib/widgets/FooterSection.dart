import 'package:flutter/material.dart';

class FooterSection extends StatelessWidget {
  final Map<String, dynamic> footer;

  const FooterSection({super.key, required this.footer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 MAIN TITLE
          Text(
            footer['main']['title'],
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 4),

          /// 🔹 MAIN VALUE
          Text(
            footer['main']['data'].toString(),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          /// 🔹 SUB INFO
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${footer['sub']['title']} ${_formatTime(footer['sub']['data'])}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 18),

          /// 🔹 STATS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _footerStatItem(footer['left'], Colors.blue),
              _footerStatItem(footer['center'], Colors.orange),
              _footerStatItem(footer['right'], Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 MINI STAT CARD
  Widget _footerStatItem(Map<String, dynamic> item, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              item['data'].toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 OPTIONAL TIME FORMATTER
  static String _formatTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
