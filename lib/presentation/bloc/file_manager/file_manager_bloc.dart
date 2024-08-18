import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:filemanager/domain/usecase/compress_file.dart';
import 'package:filemanager/domain/usecase/copy_file.dart';
import 'package:filemanager/domain/usecase/create_directory.dart';
import 'package:filemanager/domain/usecase/delete_file.dart';
import 'package:filemanager/domain/usecase/extract_file.dart';
import 'package:filemanager/domain/usecase/move_file.dart';
import 'package:filemanager/domain/usecase/rename_file.dart';
import 'package:filemanager/domain/usecase/share_files.dart';
import 'package:path_provider/path_provider.dart';

part 'file_manager_event.dart';
part 'file_manager_state.dart';

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {
  final CompressFileUseCase _compressFileUseCase;
  final ExtractFileUseCase _extractFileUseCase;
  final CopyFileUseCase _copyFileCase;
  final RenameFileUseCase _renameFileUseCase;
  final CreateDirectoryUseCase _createDirectoryUseCase;
  final MoveFileUseCase _moveFileUseCase;
  final DeleteFileUseCase _deleteFileUseCase;
  final ShareFileUseCase _shareFileUseCase;

  FileManagerBloc(
    final CompressFileUseCase compressFileUseCase,
    final ExtractFileUseCase extractFileUseCase,
    final CopyFileUseCase copyFileCase,
    final RenameFileUseCase renameFileUseCase,
    final CreateDirectoryUseCase createDirectoryUseCase,
    final MoveFileUseCase moveFileUseCase,
    final DeleteFileUseCase deleteFileUseCase,
    final ShareFileUseCase shareFileUseCase,
  )   : _compressFileUseCase = compressFileUseCase,
        _extractFileUseCase = extractFileUseCase,
        _copyFileCase = copyFileCase,
        _renameFileUseCase = renameFileUseCase,
        _createDirectoryUseCase = createDirectoryUseCase,
        _moveFileUseCase = moveFileUseCase,
        _deleteFileUseCase = deleteFileUseCase,
        _shareFileUseCase = shareFileUseCase,
        super(FileManagerState.initial()) {
    on<ChangeCurrentDirectory>(_changeCurrentDirectory);
    on<DeleteFile>(_deleteFile);
    on<RenameFile>(_renameFile);
    on<CreateDirectory>(_createDirectory);
    on<CopyFile>(_copyFile);
    on<MoveFile>(_moveFile);
    on<CompressFiles>(_compressFiles);
    on<ExtractFiles>(_extractFiles);
    on<ShareFile>(_shareFile);
  }

  FutureOr<void> _changeCurrentDirectory(
      ChangeCurrentDirectory event, Emitter<FileManagerState> emit) async {
    try {
      if (state.rootDirectory.isEmpty) {
        final rootDirectory = await _determineRootDirectory();
        emit(state.copyWith(rootDirectory: rootDirectory));
      }
      if (event.directory.path == state.currentDirectory?.path ||
          !await event.directory.exists()) {
        return;
      }

      log('Loading files...');

      final files = await Directory(
              event.directory.path.length < state.rootDirectory.length
                  ? state.rootDirectory
                  : event.directory.path)
          .list()
          .toList();
      if (!state._showHidden) {
        files.removeWhere((file) => file.name.startsWith('.'));
      }
      emit(state.copyWith(
        files: _getSortedFiles(files),
        currentDirectory: event.directory,
        isLoading: false,
      ));
    } catch (error) {
      log('Error: $error');
      emit(state.copyWith(error: error.toString(), isLoading: false));
    }
  }

  FutureOr<void> _deleteFile(
      DeleteFile event, Emitter<FileManagerState> emit) async {
    final files =
        state.files.where((file) => !event.files.contains(file)).toList();

    emit(state.copyWith(files: files));
    final result =
        await _deleteFileUseCase(DeleteFileParms(files: event.files));
    result.fold((error) => emit(state.copyWith(error: error.message)), (_) {});
  }

  FutureOr<void> _renameFile(
      RenameFile event, Emitter<FileManagerState> emit) async {
    final result = await _renameFileUseCase(
        RenameFileParms(file: event.file, newName: event.newName));
    result.fold((error) => emit(state.copyWith(error: error.message)),
        (updatedFile) {
      final files = state.files
          .map((file) => file == event.file ? updatedFile : file)
          .toList();
      final sortedFiles = _getSortedFiles(files);

      emit(state.copyWith(files: sortedFiles));
    });
  }

  List<FileSystemEntity> _getSortedFiles(List<FileSystemEntity> files) {
    return files
      ..sort((a, b) {
        if (state.sortBy == SortBy.name) {
          if (a is Directory && b is File) {
            return -1;
          } else if (a is File && b is Directory) {
            return 1;
          } else {
            return a.name.compareTo(b.name);
          }
        } else if (state.sortBy == SortBy.date) {
          return a.statSync().modified.compareTo(b.statSync().modified);
        } else {
          return a.statSync().size.compareTo(b.statSync().size);
        }
      });
  }

  FutureOr<void> _createDirectory(
      CreateDirectory event, Emitter<FileManagerState> emit) async {
    final result = await _createDirectoryUseCase(CreateDirectoryParms(
        directory: event.directory as Directory, name: event.directoryName));

    result.fold((error) => emit(state.copyWith(error: error.message)),
        (directory) {
      final files = _getSortedFiles([...state.files, directory]);
      emit(state.copyWith(files: files));
    });
  }

  FutureOr<void> _copyFile(
      CopyFile event, Emitter<FileManagerState> emit) async {
    if (event.files.firstOrNull?.parent == state.currentDirectory) {
      emit(state.copyWith(error: 'Cannot copy files to the same directory'));
      return;
    }

    final result = await _copyFileCase(CopyFileParms(
      files: event.files,
      destination: state.currentDirectory as Directory,
    ));

    result.fold(
      (error) => emit(state.copyWith(error: error.message)),
      (copiedFiles) {
        final updatedFiles =
            _getUpdatedFiles(event.files, state.currentDirectory! as Directory);
        final sortedFiles = _getSortedFiles([...state.files, ...updatedFiles]);
        emit(state.copyWith(files: sortedFiles));
      },
    );
  }

  FutureOr<void> _moveFile(
      MoveFile event, Emitter<FileManagerState> emit) async {
    if (event.files.firstOrNull?.parent == state.currentDirectory) {
      emit(state.copyWith(error: 'Cannot move files to the same directory'));
      return;
    }

    final result = await _moveFileUseCase(MoveFileParms(
      files: event.files,
      destination: state.currentDirectory as Directory,
    ));

    result.fold(
      (error) => emit(state.copyWith(error: error.message)),
      (movedFiles) {
        final updatedFiles =
            _getUpdatedFiles(event.files, state.currentDirectory! as Directory);
        final sortedFiles = _getSortedFiles([...state.files, ...updatedFiles]);
        emit(state.copyWith(files: sortedFiles));
      },
    );
  }

  Iterable<FileSystemEntity> _getUpdatedFiles(
      Set<FileSystemEntity> files, Directory destination) {
    return files.map((file) {
      final newPath = '${destination.path}/${file.uri.pathSegments.last}';
      return file is Directory ? Directory(newPath) : File(newPath);
    });
  }

  Future<String> _determineRootDirectory() async {
    if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '';
    }

    if (Platform.isIOS) {
      return '/';
    }

    if (Platform.isAndroid) {
      final applicationDirectory = await getExternalStorageDirectory();
      return applicationDirectory!.path
          .replaceFirst('/Android/data/com.example.filemanager/files', '');
    }

    return '/';
  }

  Future<void> _compressFiles(
      CompressFiles event, Emitter<FileManagerState> emit) async {
    final result =
        await _compressFileUseCase(CompressFileParms(files: event.files));

    result.fold((error) => emit(state.copyWith(error: error.message)), (_) {});
  }

  FutureOr<void> _extractFiles(
      ExtractFiles event, Emitter<FileManagerState> emit) async {
    final result =
        await _extractFileUseCase(ExtractFileParms(file: event.file));

    result.fold((error) => emit(state.copyWith(error: error.message)), (_) {});
  }

  FutureOr<void> _shareFile(
      ShareFile event, Emitter<FileManagerState> emit) async {
    final result = await _shareFileUseCase(ShareFileParams(files: event.files));
    result.fold(
        (error) => emit(state.copyWith(error: error.message)), (result) {});
  }
}
