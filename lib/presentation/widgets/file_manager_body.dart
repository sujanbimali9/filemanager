import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/widgets/item_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileManagerBody extends StatefulWidget {
  const FileManagerBody({super.key});

  @override
  FileManagerBodyState createState() => FileManagerBodyState();
}

class FileManagerBodyState extends State<FileManagerBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  String? currentDirectory;
  late final ScrollController _scrollController;
  final Map<String, double> _scrollOffsets = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      lowerBound: 0.5,
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (currentDirectory != null) {
      _scrollOffsets[currentDirectory!] = _scrollController.offset;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: BlocBuilder<FileManagerBloc, FileManagerState>(
        builder: (context, state) {
          if (currentDirectory != state.currentDirectory?.path) {
            final scrollOffset = _scrollOffsets[state.currentDirectory!.path];
            if (scrollOffset != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollController.jumpTo(scrollOffset);
              });
            }
            _controller.reset();
            _controller.forward();
            currentDirectory = state.currentDirectory?.path;
          }

          currentDirectory = state.currentDirectory?.path;
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.files.isEmpty) {
            return const Center(
              child: Text('Empty'),
            );
          }

          return SlideTransition(
            position: _offsetAnimation,
            child: FadeTransition(
              opacity: _controller.drive(
                CurveTween(curve: Curves.easeInSine),
              ),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.files.length,
                itemBuilder: (context, index) {
                  final file = state.files[index];

                  return ItemListTile(file: file);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
