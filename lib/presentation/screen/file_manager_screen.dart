// import 'dart:developer';
// import 'dart:io';

// import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
// import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
// import 'package:filemanager/presentation/widgets/animated_bottom_builder.dart';
// import 'package:filemanager/presentation/widgets/bottom_navigation.dart';
// import 'package:filemanager/presentation/widgets/file_manager_body.dart';
// import 'package:filemanager/presentation/widgets/file_manager_header.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class FileManagerScreen extends StatefulWidget {
//   const FileManagerScreen({super.key, this.home});
//   final String? home;

//   @override
//   State<FileManagerScreen> createState() => _FileManagerScreenState();
// }

// class _FileManagerScreenState extends State<FileManagerScreen> {
//   late final SelectedItemsCubit selectedItemsCubit;
//   late final FileManagerBloc fileManagerBloc;
//   late final Directory dir;
//   late final ScrollController scrollController;
//   late final Map<String, dynamic> scrollPosition;

//   @override
//   void initState() {
//     scrollController = ScrollController();
//     scrollPosition = {};
//     fileManagerBloc = context.read<FileManagerBloc>();
//     selectedItemsCubit = context.read<SelectedItemsCubit>();
//     dir = Directory(
//         widget.home ?? Platform.environment['HOME'] ?? '/storage/emulated/0');
//     fileManagerBloc.add(ChangeCurrentDirectory(dir));

//     super.initState();
//   }

//   @override
//   void dispose() {
//     fileManagerBloc.add(ChangeCurrentDirectory(dir));
//     selectedItemsCubit.clear();
//     super.dispose();
//   }

//   Future<void> navigateBack(BuildContext context) async {
//     log('navigateBack');
//     final state = fileManagerBloc.state;
//     if (selectedItemsCubit.state.selectedItems.isNotEmpty) {
//       selectedItemsCubit.clear();
//       return;
//     } else if (state.isRoot) {
//       if (Navigator.of(context).canPop()) {
//         Navigator.of(context).pop();
//       }
//       return;
//     }
//     if (state.currentDirectory != null &&
//         state.currentDirectory?.parent != null) {
//       fileManagerBloc
//           .add(ChangeCurrentDirectory(state.currentDirectory!.parent));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) async {
//           await navigateBack(context);
//         },
//         child: const Column(
//           children: [
//             SizedBox(height: 20),
//             FileManagerHeader(),
//             Expanded(child: FileManagerBody()),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: Colors.white,
//         child: BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
//           buildWhen: (previous, current) {
//             return previous.selectedItems.isNotEmpty !=
//                     current.selectedItems.isNotEmpty ||
//                 previous.runtimeType != current.runtimeType;
//           },
//           builder: (context, state) {
//             final child2 = state is CopySelectedItemsState ||
//                     state is MoveSelectedItemsState
//                 ? CopyOrPasteBottomNavigation(
//                     itemCount: state is CopySelectedItemsState
//                         ? (state).copyingItems.length
//                         : (state as MoveSelectedItemsState).movingItems.length,
//                     title: state is CopySelectedItemsState ? 'Paste' : 'Move',
//                     onPressed: () {
//                       if (state is CopySelectedItemsState) {
//                         fileManagerBloc.add(CopyFile(
//                             (fileManagerBloc.state as CopySelectedItemsState)
//                                 .copyingItems
//                                 .toList()));
//                         selectedItemsCubit.initial();
//                       } else {
//                         fileManagerBloc.add(MoveFile(
//                             (fileManagerBloc.state as MoveSelectedItemsState)
//                                 .movingItems
//                                 .toList()));
//                         selectedItemsCubit.initial();
//                       }
//                     },
//                   )
//                 : null;
//             final bool showFirst = state.selectedItems.isNotEmpty;
//             return AnimatedBottomBuilder(
//               child1: FileManagerBottomNavigation(
//                 onCopy: () {
//                   selectedItemsCubit.copyAll();
//                 },
//                 onCut: () {
//                   selectedItemsCubit.moveAll();
//                 },
//                 onDelete: () {
//                   fileManagerBloc
//                       .add(DeleteFile(selectedItemsCubit.state.selectedItems));
//                   selectedItemsCubit.clear();
//                 },
//               ),
//               child2: child2,
//               firstChild: showFirst,
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class CopyOrPasteBottomNavigation extends StatelessWidget {
//   const CopyOrPasteBottomNavigation({
//     super.key,
//     this.onPressed,
//     required this.itemCount,
//     required this.title,
//   });
//   final VoidCallback? onPressed;
//   final int itemCount;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         const SizedBox(width: 20),
//         Text('$itemCount items selected'),
//         const Spacer(),
//         TextButton(
//           onPressed: () {
//             context.read<SelectedItemsCubit>().initial();
//           },
//           child: const Text('Cancel'),
//         ),
//         const SizedBox(width: 20),
//         TextButton(
//           onPressed: onPressed,
//           child: Text(title),
//         ),
//       ],
//     );
//   }
// }

import 'dart:developer';
import 'dart:io';

import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:filemanager/presentation/widgets/animated_bottom_builder.dart';
import 'package:filemanager/presentation/widgets/bottom_navigation.dart';
import 'package:filemanager/presentation/widgets/file_manager_body.dart';
import 'package:filemanager/presentation/widgets/file_manager_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key, this.home});
  final String? home;

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  late final SelectedItemsCubit selectedItemsCubit;
  late final FileManagerBloc fileManagerBloc;
  late final Directory dir;
  late final ScrollController scrollController;
  late final Map<String, dynamic> scrollPosition;

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();
    scrollPosition = {};
    fileManagerBloc = context.read<FileManagerBloc>();
    selectedItemsCubit = context.read<SelectedItemsCubit>();
    dir = Directory(widget.home ?? '/storage/emulated/0');

    fileManagerBloc.add(ChangeCurrentDirectory(dir));
  }

  @override
  void dispose() {
    selectedItemsCubit.clear();
    fileManagerBloc.add(ChangeCurrentDirectory(Directory('/')));
    scrollController.dispose();

    super.dispose();
  }

  Future<void> navigateBack(BuildContext context) async {
    log('navigateBack');
    final state = fileManagerBloc.state;

    if (selectedItemsCubit.state.selectedItems.isNotEmpty) {
      selectedItemsCubit.clear();
      return;
    }

    if (state.isRoot && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (state.currentDirectory?.parent != null) {
      fileManagerBloc
          .add(ChangeCurrentDirectory(state.currentDirectory!.parent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          await navigateBack(context);
        },
        child: const Column(
          children: [
            SizedBox(height: 20),
            FileManagerHeader(),
            Expanded(child: FileManagerBody()),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
          buildWhen: (previous, current) {
            return previous.selectedItems.isNotEmpty !=
                    current.selectedItems.isNotEmpty ||
                previous.runtimeType != current.runtimeType;
          },
          builder: (context, state) {
            final bool showFirst = state.selectedItems.isNotEmpty;
            final child2 = _buildCopyOrPasteNavigation(context, state);

            return AnimatedBottomBuilder(
              child1: FileManagerBottomNavigation(
                onCopy: selectedItemsCubit.copyAll,
                onCut: selectedItemsCubit.moveAll,
                onDelete: () {
                  fileManagerBloc
                      .add(DeleteFile(selectedItemsCubit.state.selectedItems));
                  selectedItemsCubit.clear();
                },
              ),
              child2: child2,
              firstChild: showFirst,
            );
          },
        ),
      ),
    );
  }

  Widget? _buildCopyOrPasteNavigation(
      BuildContext context, SelectedItemsState state) {
    if (state is CopySelectedItemsState || state is MoveSelectedItemsState) {
      final itemCount = state is CopySelectedItemsState
          ? state.copyingItems.length
          : (state as MoveSelectedItemsState).movingItems.length;

      final title = state is CopySelectedItemsState ? 'Paste' : 'Move';

      return CopyOrPasteBottomNavigation(
        itemCount: itemCount,
        title: title,
        onPressed: () {
          if (state is CopySelectedItemsState) {
            fileManagerBloc.add(CopyFile(state.copyingItems));
          } else if (state is MoveSelectedItemsState) {
            fileManagerBloc.add(MoveFile(state.movingItems));
          }
          selectedItemsCubit.initial();
        },
      );
    }

    return null;
  }
}

class CopyOrPasteBottomNavigation extends StatelessWidget {
  const CopyOrPasteBottomNavigation({
    super.key,
    required this.itemCount,
    required this.title,
    this.onPressed,
  });

  final VoidCallback? onPressed;
  final int itemCount;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        Text('$itemCount items selected'),
        const Spacer(),
        TextButton(
          onPressed: () => context.read<SelectedItemsCubit>().initial(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 20),
        TextButton(
          onPressed: onPressed,
          child: Text(title),
        ),
      ],
    );
  }
}
