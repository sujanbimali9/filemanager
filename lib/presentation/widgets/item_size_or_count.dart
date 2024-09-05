import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class ItemSizeorCount extends StatelessWidget {
  const ItemSizeorCount({
    super.key,
    required this.file,
  });

  final FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    final file = this.file;
    return FutureBuilder(
        future: (file is Directory) ? ((file).list().length) : file.stat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('');
          }
          if (file is Directory) {
            final length = snapshot.data as int?;

            return Text('${length ?? 0} items');
          } else {
            final stat = snapshot.data as FileStat;
            return Text(_formatBytes(stat.size, 2));
          }
        });
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return '0 Bytes';
    const suffixes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
