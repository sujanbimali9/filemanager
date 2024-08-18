import 'dart:io';

import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/failure.dart';
import 'package:filemanager/usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:share_plus/share_plus.dart';

class ShareFileUseCase implements UseCase<ShareResult, ShareFileParams> {
  final FileManagerLocalRepository _localRepository;

  ShareFileUseCase(FileManagerLocalRepository localRepository)
      : _localRepository = localRepository;
  @override
  Future<Either<Failure, ShareResult>> call(ShareFileParams parms) async {
    return await _localRepository.shareFile(parms.files);
  }
}

class ShareFileParams {
  final Set<FileSystemEntity> files;

  ShareFileParams({required this.files});
}
