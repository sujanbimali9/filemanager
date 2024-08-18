import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';

class ExtractFileUseCase implements UseCase<void, ExtractFileParms> {
  final FileManagerLocalRepository _localRepository;

  ExtractFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, void>> call(ExtractFileParms parms) async {
    return await _localRepository.extractFile(parms.file);
  }
}

class ExtractFileParms {
  final FileSystemEntity file;

  ExtractFileParms({required this.file});
}
