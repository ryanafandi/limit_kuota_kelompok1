import 'package:flutter/material.dart';
import 'package:limit_kuota/src/core/data/database_helper.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<Map<String, dynamic>>> _historyList;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyList = DatabaseHelper.instance.getHistory();
    });
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return "0.00 MB";
    double mb = bytes / (1024 * 1024);
    if (mb > 1024) {
      return "${(mb / 1024).toStringAsFixed(2)} GB";
    }
    return "${mb.toStringAsFixed(2)} MB";
  }

  double _getProgress(Map item) {
    try {
      int wifi = item['wifi'] ?? 0;
      int mobile = item['mobile'] ?? 0;

      double totalMB = (wifi + mobile) / (1024 * 1024);
      double progress = totalMB / 2000; // asumsi 2GB

      if (progress > 1) return 1;
      return progress;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ICON + TEXT (aul)
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history, size: 18, color: Colors.blue),
            ),
            const SizedBox(width: 10),
            const Text(
              "Riwayat Penggunaan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),

      //  BACKGROUND
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEFF6FF), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _historyList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada riwayat data."));
            }

            final data = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),

                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(16),

                      child: Column(
                        children: [
                          Row(
                            children: [
                              //  ICON MODERN
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Text(
                                  item['date'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          //  DATA SECTION(ryan)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.wifi,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatBytes(item['wifi']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.signal_cellular_alt,
                                    size: 18,
                                    color: Colors.purple,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatBytes(item['mobile']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          //  PROGRESS BAR
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: _getProgress(item),
                              minHeight: 6,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
