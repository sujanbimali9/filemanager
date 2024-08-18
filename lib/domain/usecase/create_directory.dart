import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class CreateDirectoryUseCase
    implements UseCase<Directory, CreateDirectoryParms> {
  final FileManagerLocalRepository _localRepository;

  CreateDirectoryUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, Directory>> call(CreateDirectoryParms parms) async {
    return await _localRepository.createDirectory(parms.directory, parms.name);
  }
}

class CreateDirectoryParms {
  final Directory directory;
  final String name;

  CreateDirectoryParms({required this.directory, required this.name});
}
