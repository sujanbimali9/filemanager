import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class MoveFileUseCase implements UseCase<void, MoveFileParms> {
  final FileManagerLocalRepository _localRepository;

  MoveFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, void>> call(parms) async {
    return await _localRepository.moveFile(parms.files, parms.destination);
  }
}

class MoveFileParms {
  final Set<FileSystemEntity> files;
  final Directory destination;

  MoveFileParms({required this.files, required this.destination});
}
