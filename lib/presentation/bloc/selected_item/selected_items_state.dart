part of 'selected_items_cubit.dart';

class SelectedItemsState extends Equatable {
  final Set<FileSystemEntity> selectedItems;

  const SelectedItemsState({required this.selectedItems});

  @override
  List<Object> get props => [
        selectedItems,
      ];

  SelectedItemsState copyWith({
    Set<FileSystemEntity>? selectedItems,
  }) {
    return SelectedItemsState(
      selectedItems: selectedItems ?? this.selectedItems,
    );
  }
}

class CopySelectedItemsState extends SelectedItemsState {
  final Set<FileSystemEntity> copyingItems;

  const CopySelectedItemsState({
    required super.selectedItems,
    required this.copyingItems,
  });

  @override
  List<Object> get props => [
        ...super.props,
        copyingItems,
      ];

  @override
  CopySelectedItemsState copyWith({
    Set<FileSystemEntity>? selectedItems,
    Set<FileSystemEntity>? copyingItems,
  }) {
    return CopySelectedItemsState(
      selectedItems: selectedItems ?? this.selectedItems,
      copyingItems: copyingItems ?? this.copyingItems,
    );
  }
}

class MoveSelectedItemsState extends SelectedItemsState {
  final Set<FileSystemEntity> movingItems;

  const MoveSelectedItemsState({
    required super.selectedItems,
    required this.movingItems,
  });

  @override
  List<Object> get props => [
        ...super.props,
        movingItems,
      ];

  @override
  MoveSelectedItemsState copyWith({
    Set<FileSystemEntity>? selectedItems,
    Set<FileSystemEntity>? movingItems,
  }) {
    return MoveSelectedItemsState(
      selectedItems: selectedItems ?? this.selectedItems,
      movingItems: movingItems ?? this.movingItems,
    );
  }
}
