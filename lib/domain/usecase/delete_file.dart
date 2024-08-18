import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class DeleteFileUseCase implements UseCase<void, DeleteFileParms> {
  final FileManagerLocalRepository _localRepository;
  DeleteFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, void>> call(DeleteFileParms parms) async {
    return await _localRepository.deleteFile(parms.files);
  }
}

class DeleteFileParms {
  final Set<FileSystemEntity> files;
  DeleteFileParms({required this.files});
}
