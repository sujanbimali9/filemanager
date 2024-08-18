part of 'quick_access_bloc.dart';

sealed class QuickAccessEvent extends Equatable {
  const QuickAccessEvent();

  @override
  List<Object> get props => [];
}

class LoadFiles extends QuickAccessEvent {
  const LoadFiles();
}

class DeleteQuickAccessFile extends QuickAccessEvent {
  final Set<FileSystemEntity> files;
  final String type;
  const DeleteQuickAccessFile(this.files, this.type);
  @override
  List<Object> get props => [files];
}
