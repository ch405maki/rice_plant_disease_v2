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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete scan?',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this plant disease?\n'
          'This cannot be undone.',
          textAlign: TextAlign.start,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.scans.deleteAt(index);
    }
  }

  Widget _buildThumbnail(SavedScan scan) {
    final bytes = scan.imageBytes;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 52,
        height: 52,
        child: bytes == null
            ? const ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.image_outlined, color: Colors.black38),
              )
            : Image.memory(bytes, fit: BoxFit.cover),
      ),
    );
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