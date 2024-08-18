import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'selected_items_state.dart';

class SelectedItemsCubit extends Cubit<SelectedItemsState> {
  SelectedItemsCubit()
      : super(const SelectedItemsState(selectedItems: <FileSystemEntity>{}));

  void toggleItem(FileSystemEntity item) {
    final selectedItems = Set<FileSystemEntity>.from(state.selectedItems);
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
    emit(state.copyWith(selectedItems: selectedItems));
  }

  void clear() {
    emit(state.copyWith(selectedItems: <FileSystemEntity>{}));
  }

  void initial() {
    emit(const SelectedItemsState(selectedItems: <FileSystemEntity>{}));
  }

  void addAll(List<FileSystemEntity> items) {
    final selectedItems = Set<FileSystemEntity>.from(state.selectedItems);
    selectedItems.addAll(items);
    emit(state.copyWith(selectedItems: selectedItems));
  }

  void copyAll() {
    emit(CopySelectedItemsState(
      selectedItems: const {},
      copyingItems: state.selectedItems,
    ));
  }

  void moveAll() {
    emit(MoveSelectedItemsState(
      selectedItems: const {},
      movingItems: state.selectedItems,
    ));
  }
}
