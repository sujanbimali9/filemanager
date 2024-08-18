import 'dart:io';

import 'package:filemanager/presentation/widgets/item_icon.dart';
import 'package:flutter/material.dart';

class RecentFiles extends StatefulWidget {
  const RecentFiles({
    super.key,
    required this.files,
    this.onTap,
    required this.scrollController,
    required this.dragController,
    this.child,
  });
  final Map<String, File> files;
  final VoidCallback? onTap;
  final Widget? child;
  final ScrollController scrollController;
  final DraggableScrollableController dragController;

  @override
  State<RecentFiles> createState() => _RecentFilesState();
}

class _RecentFilesState extends State<RecentFiles> {
  ValueNotifier<bool> isAtTop = ValueNotifier(false);

  @override
  void initState() {
    widget.dragController.addListener(_dragListener);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   widget.dragController.animateTo(0.25,
    //       duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    // });
    super.initState();
  }

  void _scrollToTop() {
    widget.dragController.animateTo(
      1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    widget.dragController.animateTo(
      0.25,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  _dragListener() {
    if (widget.dragController.size <= 0.5) {
      isAtTop.value = false;
    } else {
      isAtTop.value = true;
    }
  }

  @override
  void dispose() {
    isAtTop.dispose();
    widget.dragController.removeListener(_dragListener);
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        children: [
          Row(
            children: [
              const Text('New Files'),
              const Spacer(),
              MaterialButton(
                elevation: 0,
                hoverElevation: 3,
                color: Colors.white,
                minWidth: 50,
                height: 45,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                onPressed: () {
                  if (isAtTop.value) {
                    _scrollToBottom();
                    isAtTop.value = false;
                  } else {
                    _scrollToTop();
                    isAtTop.value = true;
                  }
                },
                child: ValueListenableBuilder(
                  valueListenable: isAtTop,
                  builder: (context, bool isAtTop, child) => Icon(isAtTop
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.files.isEmpty)
            const Center(child: Text('No files found'))
          else
            ...widget.files.entries.map(
              (e) => Column(
                children: [
                  Text(e.key),
                  const SizedBox(height: 10),
                  Column(
                    children: [
                      ItemIcon(file: e.value),
                      const SizedBox(height: 10),
                      Flexible(
                          child: Text(
                        e.value.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      )),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
