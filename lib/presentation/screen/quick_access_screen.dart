import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/bloc/quick_access/quick_access_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:filemanager/presentation/screen/file_manager_screen.dart';
import 'package:filemanager/presentation/widgets/animated_bottom_builder.dart';
import 'package:filemanager/presentation/widgets/bottom_navigation.dart';
import 'package:filemanager/presentation/widgets/item_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickAccessScreen extends StatefulWidget {
  const QuickAccessScreen({super.key, required this.title, required this.type});
  final String title;
  final String type;

  @override
  State<QuickAccessScreen> createState() => _QuickAccessScreenState();
}

class _QuickAccessScreenState extends State<QuickAccessScreen> {
  late final SelectedItemsCubit _selectedItemsCubit;
  @override
  void initState() {
    _selectedItemsCubit = context.read<SelectedItemsCubit>();
    super.initState();
  }

  @override
  void dispose() {
    _selectedItemsCubit.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomScrollView(
          slivers: [
            BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
              buildWhen: (previous, current) {
                return previous.selectedItems.isNotEmpty !=
                        current.selectedItems.isNotEmpty ||
                    current.selectedItems.length ==
                        context
                            .read<QuickAccessBloc>()
                            .state
                            .getFiles(widget.type)
                            .length;
              },
              builder: (context, state) {
                final selectedItems = state.selectedItems;
                final isSelected = selectedItems.isNotEmpty;
                final allSelected = selectedItems.length ==
                    context
                        .read<QuickAccessBloc>()
                        .state
                        .getFiles(widget.type)
                        .length;

                return SliverAppBar(
                  backgroundColor: const Color.fromARGB(255, 228, 228, 230),
                  surfaceTintColor: Colors.white,
                  floating: !isSelected,
                  pinned: isSelected,
                  title: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    if (isSelected)
                      IconButton(
                        onPressed: () {
                          if (allSelected) {
                            _selectedItemsCubit.clear();
                          } else {
                            final files = context
                                .read<QuickAccessBloc>()
                                .state
                                .getFiles(widget.type);
                            _selectedItemsCubit.addAll(files);
                          }
                        },
                        icon: Icon(
                            allSelected
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_outlined,
                            color: allSelected
                                ? const Color.fromARGB(255, 68, 0, 255)
                                : Colors.black),
                      ),
                    const SizedBox(width: 20),
                  ],
                );
              },
            ),
            BlocBuilder<QuickAccessBloc, QuickAccessState>(
              buildWhen: (previous, current) {
                return previous.getFiles(widget.type) !=
                    current.getFiles(widget.type);
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final files = state.getFiles(widget.type);

                if (files.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text('No files found'),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    return ItemListTile(file: files[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
        buildWhen: (previous, current) {
          return previous.selectedItems.isNotEmpty !=
              current.selectedItems.isNotEmpty;
        },
        builder: (context, state) {
          final fileManagerBloc = context.read<FileManagerBloc>();
          final selectedItemsCubit = context.read<SelectedItemsCubit>();
          final child2 = state is CopySelectedItemsState ||
                  state is MoveSelectedItemsState
              ? CopyOrPasteBottomNavigation(
                  itemCount: state is CopySelectedItemsState
                      ? (state).copyingItems.length
                      : (state as MoveSelectedItemsState).movingItems.length,
                  title: state is CopySelectedItemsState ? 'Paste' : 'Move',
                  onPressed: () {
                    if (state is CopySelectedItemsState) {
                      fileManagerBloc.add(CopyFile(state.copyingItems));
                      selectedItemsCubit.initial();
                    } else {
                      fileManagerBloc.add(MoveFile(
                          (state as MoveSelectedItemsState).movingItems));
                      selectedItemsCubit.initial();
                    }
                  },
                )
              : null;
          return AnimatedBottomBuilder(
            child1: FileManagerBottomNavigation(
              onCopy: () {
                _selectedItemsCubit.copyAll();
              },
              onCut: () {
                _selectedItemsCubit.moveAll();
              },
              onDelete: () {
                context.read<QuickAccessBloc>().add(DeleteQuickAccessFile(
                    _selectedItemsCubit.state.selectedItems, widget.type));
                _selectedItemsCubit.clear();
              },
              onShare: () {
                context
                    .read<FileManagerBloc>()
                    .add(ShareFile(state.selectedItems));
              },
            ),
            firstChild: state.selectedItems.isNotEmpty,
            child2: child2,
          );
        },
      ),
    );
  }
}
