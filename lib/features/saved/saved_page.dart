import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/saved_scan.dart';
import '../../data/repositories/scan_repository.dart';
import 'saved_detail_page.dart';

/// Lists saved scans from the local Hive box, with delete support.
class SavedPage extends StatefulWidget {
  const SavedPage({Key? key, required this.scans}) : super(key: key);

  final ScanRepository scans;

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  Future<void> _confirmDelete(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete this plant disease?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.scans.deleteAt(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<SavedScan>>(
      valueListenable: widget.scans.listenable,
      builder: (context, box, _) {
        final scans = widget.scans.scans;
        if (scans.isEmpty) {
          return const Center(child: Text('No plant diseases found.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                leading: _buildThumbnail(scan),
                title: Text(
                  scan.plantName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(formatTimestamp(scan.dateCreated)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(index),
                ),
                onTap: () => Navigator.of(context).push<SavedDetailPage>(
                  MaterialPageRoute<SavedDetailPage>(
                    builder: (_) => SavedDetailPage(scan: scan),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}