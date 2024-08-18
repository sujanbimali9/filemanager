import 'package:flutter/material.dart';

// class AnimatedBottomNavigation extends StatelessWidget {
//   const AnimatedBottomNavigation({
//     super.key,
//     this.onCopy,
//     this.onCut,
//     this.onDelete,
//     this.onShare,
//   });

//   final VoidCallback? onCopy;
//   final VoidCallback? onCut;
//   final VoidCallback? onDelete;
//   final VoidCallback? onShare;
//   @override
//   Widget build(BuildContext context) {
//     final SelectedItemsCubit selectedItemsCubit =
//         context.read<SelectedItemsCubit>();
//     return BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
//       builder: (context, state) {
//         final selectedItems = state.selectedItems;
//         final isSelected = selectedItems.isNotEmpty;
//         log('isSelected: $isSelected');
//         return AnimatedSlide(
//           offset: isSelected ? const Offset(0, 0) : const Offset(0, 0),
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeInOut,
//           child: isSelected
//               ? Container(
//                   height: 70,
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(20),
//                     ),
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: Offset(0, -5),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       const SizedBox(width: 20),
//                       IconButton(
//                         onPressed: onCopy,
//                         icon: const Icon(Icons.copy),
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         onPressed: onCut,
//                         icon: const Icon(Icons.cut),
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         onPressed: onDelete,
//                         icon: const Icon(Icons.delete),
//                       ),
//                       const Spacer(),
//                       IconButton(
//                         onPressed: onShare,
//                         icon: const Icon(Icons.share),
//                       ),
//                       const SizedBox(width: 20),
//                     ],
//                   ),
//                 )
//               : state is CopySelectedItemsState
//                   ? Container(
//                       height: 70,
//                       decoration: const BoxDecoration(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(20),
//                         ),
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 10,
//                             offset: Offset(0, -5),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           const SizedBox(width: 20),
//                           Text(
//                             '${state.copyingItems.length} items',
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                           const Spacer(),
//                           TextButton(
//                             onPressed: () {},
//                             child: const Text('Cancel'),
//                           ),
//                           const SizedBox(width: 20),
//                           TextButton(
//                             onPressed: () {
//                               context
//                                   .read<FileManagerBloc>()
//                                   .add(CopyFile(state.copyingItems.toList()));
//                               selectedItemsCubit.clear();
//                             },
//                             child: const Text('Copy'),
//                           ),
//                           const SizedBox(width: 20),
//                         ],
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//         );
//       },
//     );
//   }
// }

class FileManagerBottomNavigation extends StatelessWidget {
  const FileManagerBottomNavigation(
      {super.key, this.onCopy, this.onCut, this.onDelete, this.onShare});
  final VoidCallback? onCopy;
  final VoidCallback? onCut;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 20),
        IconButton(onPressed: onCopy, icon: const Icon(Icons.copy)),
        const Spacer(),
        IconButton(onPressed: onCut, icon: const Icon(Icons.cut)),
        const Spacer(),
        IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
        const Spacer(),
        IconButton(onPressed: onShare, icon: const Icon(Icons.share)),
        const SizedBox(width: 20),
      ],
    );
  }
}
