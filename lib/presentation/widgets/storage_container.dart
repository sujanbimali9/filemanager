import 'dart:math';

import 'package:flutter/material.dart';

class StorageContainer extends StatelessWidget {
  const StorageContainer(
      {super.key,
      required this.totalStorage,
      required this.usedStorage,
      required this.icon,
      required this.title,
      required this.onTap,
      this.onMoreTap,
      this.width});

  final int totalStorage;
  final int usedStorage;
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    String formatBytes(int bytes, int decimals) {
      if (bytes <= 0) return '0 Bytes';
      const suffixes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
      final i = (log(bytes) / log(1024)).floor();
      final size = bytes / pow(1024, i);
      return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 5),
                Text(
                  ' ${formatBytes(usedStorage, 1)}/ ${formatBytes(totalStorage, 1)}',
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (totalStorage != 0)
                  LinearProgressIndicator(
                    minHeight: 5,
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    value: usedStorage / totalStorage,
                    backgroundColor: Colors.white,
                    color: Colors.blue.withOpacity(0.5),
                  ),
                const SizedBox(height: 10),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                  onPressed: onMoreTap,
                  icon: const Icon(Icons.more_vert, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
