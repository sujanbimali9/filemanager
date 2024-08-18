import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class RenameFileUseCase implements UseCase<FileSystemEntity, RenameFileParms> {
  final FileManagerLocalRepository _localRepository;

  RenameFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, FileSystemEntity>> call(parms) async {
    return await _localRepository.renameFile(parms.file, parms.newName);
  }
}

class RenameFileParms {
  final FileSystemEntity file;
  final String newName;

  RenameFileParms({required this.file, required this.newName});
}
