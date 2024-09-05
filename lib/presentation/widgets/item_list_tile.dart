import 'dart:io';

import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:filemanager/presentation/widgets/item_icon.dart';
import 'package:filemanager/presentation/widgets/item_size_or_count.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.file,
  });

  final FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    final itemSizeOrCount = ItemSizeorCount(file: file);

    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Text(
        file.path.split('/').last,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: itemSizeOrCount,
      leading: ItemIcon(file: file),
      onTap: () {
        final state = context.read<SelectedItemsCubit>().state;
        if (state.selectedItems.isNotEmpty) {
          context.read<SelectedItemsCubit>().toggleItem(file);
        } else if (file is Directory) {
          context.read<FileManagerBloc>().add(ChangeCurrentDirectory(file));
        }
      },
      onLongPress: () => context.read<SelectedItemsCubit>().toggleItem(file),
      trailing: BlocBuilder<SelectedItemsCubit, SelectedItemsState>(
        buildWhen: (previous, current) {
          return previous.selectedItems.contains(file) !=
                  current.selectedItems.contains(file) ||
              previous.selectedItems.isEmpty != current.selectedItems.isEmpty;
        },
        builder: (context, state) {
          final isSelected = state.selectedItems.contains(file);

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: const Duration(milliseconds: 0),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              const offsetForSelected = Offset(1.0, 0.0);
              const offsetForNotSelected = Offset(0.0, 0.1);
              final isSelected = state.selectedItems.isNotEmpty;
              return SlideTransition(
                position: Tween<Offset>(
                  begin: isSelected ? offsetForSelected : offsetForNotSelected,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
            child: state.selectedItems.isNotEmpty
                ? Checkbox(
                    key: const ValueKey('checkbox'),
                    value: isSelected,
                    checkColor: Colors.white,
                    activeColor: const Color.fromARGB(255, 68, 0, 255),
                    onChanged: (_) {
                      context.read<SelectedItemsCubit>().toggleItem(file);
                    },
                  )
                : InkWell(
                    onTap: () {},
                    radius: 20,
                    borderRadius: BorderRadius.circular(20),
                    child: const SizedBox(
                      height: 45,
                      width: 45,
                      child: Icon(Icons.more_vert),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
