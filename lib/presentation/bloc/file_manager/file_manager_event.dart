part of 'file_manager_bloc.dart';

sealed class FileManagerEvent extends Equatable {
  const FileManagerEvent();

  @override
  List<Object> get props => [];
}

class ChangeCurrentDirectory extends FileManagerEvent {
  final FileSystemEntity directory;
  const ChangeCurrentDirectory(this.directory);
  @override
  List<Object> get props => [directory];
}

final class DeleteFile extends FileManagerEvent {
  final Set<FileSystemEntity> files;
  const DeleteFile(this.files);
  @override
  List<Object> get props => [files];
}

final class RenameFile extends FileManagerEvent {
  final FileSystemEntity file;
  final String newName;
  const RenameFile(this.file, this.newName);
  @override
  List<Object> get props => [file, newName];
}

final class CreateDirectory extends FileManagerEvent {
  final FileSystemEntity directory;
  final String directoryName;
  const CreateDirectory(this.directory, this.directoryName);
  @override
  List<Object> get props => [directory, directoryName];
}

final class CopyFile extends FileManagerEvent {
  final Set<FileSystemEntity> files;
  const CopyFile(this.files);
  @override
  List<Object> get props => [files];
}

final class MoveFile extends FileManagerEvent {
  final Set<FileSystemEntity> files;
  const MoveFile(this.files);
  @override
  List<Object> get props => [files];
}

final class CompressFiles extends FileManagerEvent {
  final Set<FileSystemEntity> files;
  final FileSystemEntity destination;
  const CompressFiles(this.files, this.destination);
  @override
  List<Object> get props => [files, destination];
}

final class ExtractFiles extends FileManagerEvent {
  final FileSystemEntity file;
  final FileSystemEntity destination;
  const ExtractFiles(this.file, this.destination);
  @override
  List<Object> get props => [file, destination];
}

class ShareFile extends FileManagerEvent {
  final Set<FileSystemEntity> files;
  const ShareFile(this.files);
  @override
  List<Object> get props => [files];
}
