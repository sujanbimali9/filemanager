import 'dart:io';

import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileManagerHeader extends StatefulWidget {
  const FileManagerHeader({super.key});

  @override
  State<FileManagerHeader> createState() => _FileManagerHeaderState();
}

class _FileManagerHeaderState extends State<FileManagerHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  String currentPath = '';

  @override
  void initState() {
    _controller = AnimationController(
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: BlocBuilder<FileManagerBloc, FileManagerState>(
        buildWhen: (previous, current) {
          return previous.currentDirectory != current.currentDirectory ||
              previous.files.length != current.files.length;
        },
        builder: (context, state) {
          final fullPath = state.getReadablePath(20);
          final lastPath = fullPath.split('/').last;
          final firstPath = fullPath.split('/').first;

          if (state.files.isNotEmpty && currentPath != fullPath) {
            _controller.reset();
            _controller.forward();
          }
          currentPath = fullPath;

          return SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          fullPath.split('/').last,
                          style: const TextStyle(
                            fontSize: 35,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 30),
                      Text(
                        '${state.files.length} items',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: fullPath
                        .split('/')
                        .expand(
                          (path) => [
                            if (path != firstPath) const SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                _navigateToDir(context, path);
                              },
                              child: Text(path,
                                  style: const TextStyle(color: Colors.grey)),
                            ),
                            const SizedBox(width: 5),
                            if (path != lastPath)
                              const Icon(Icons.keyboard_arrow_right_outlined,
                                  color: Colors.grey),
                          ],
                        )
                        .toList(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDir(BuildContext context, String path) {
    final fileManagerBloc = context.read<FileManagerBloc>();
    final currentDirectory = fileManagerBloc.state.currentDirectory!;
    final pathIndex = currentDirectory.path.indexOf(path) + path.length;
    if (pathIndex < currentDirectory.path.length) {
      fileManagerBloc.add(
        ChangeCurrentDirectory(Directory(fileManagerBloc.state.rootDirectory)),
      );
    }

    context.read<FileManagerBloc>().add(
          ChangeCurrentDirectory(
            Directory(
              currentDirectory.path.replaceRange(
                pathIndex,
                currentDirectory.path.length,
                '',
              ),
            ),
          ),
        );
  }
}
