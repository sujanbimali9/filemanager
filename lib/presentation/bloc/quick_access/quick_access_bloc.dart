import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:filemanager/domain/usecase/delete_file.dart';
import 'package:path_provider/path_provider.dart';

part 'quick_access_event.dart';
part 'quick_access_state.dart';

class QuickAccessBloc extends Bloc<QuickAccessEvent, QuickAccessState> {
  final DeleteFileUseCase _deleteFileUseCase;
  QuickAccessBloc(
    final DeleteFileUseCase deleteFileUseCase,
  )   : _deleteFileUseCase = deleteFileUseCase,
        super(QuickAccessState.initial()) {
    on<QuickAccessEvent>((event, emit) {});
    on<LoadFiles>(_loadFiles);
    on<DeleteQuickAccessFile>(_deleteFile);
    add(const LoadFiles());
  }

  FutureOr<void> _loadFiles(
      LoadFiles event, Emitter<QuickAccessState> emit) async {
    final home = Directory(await state.getRootDir);
    emit(state.copyWith(isLoading: true));

    try {
      log('Loading files...');
      final downloadsFuture = home.list();
      final data = await _loadData(home.path);

      final downloads = <FileSystemEntity>[];
      await for (final entity in downloadsFuture) {
        downloads.add(entity);
      }
      log('Data loaded.');

      emit(state.copyWith(
        isLoading: false,
        images: data['images'],
        videos: data['videos'],
        audios: data['audios'],
        apks: data['apks'],
        documents: data['documents'],
        compressedFiles: data['compressed'],
      ));
    } catch (error) {
      log('Error: $error');
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<Map<String, List<FileSystemEntity>>> _loadData(String path) async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_loadDataIsolate, receivePort.sendPort);

    final sendPort = await receivePort.first as SendPort;
    final resultPort = ReceivePort();
    sendPort.send([path, resultPort.sendPort]);

    final data = await resultPort.first as Map<String, List<FileSystemEntity>>;
    receivePort.close();
    resultPort.close();
    isolate.kill(priority: Isolate.immediate);
    return data;
  }

  static Future<void> _loadDataIsolate(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final extensions = {
      'images': {'jpg', 'jpeg', 'png', 'gif', 'webp'},
      'videos': {'mp4', 'mkv', 'avi', 'webm', 'flv', 'mov'},
      'audios': {'mp3', 'wav', 'ogg', 'flac', 'm4a'},
      'apks': {'apk'},
      'documents': {'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'},
      'compressed': {'zip', 'rar', '7z', 'tar', 'gz', 'bz2', 'xz'},
    };
    final data = <String, List<FileSystemEntity>>{
      'images': [],
      'videos': [],
      'audios': [],
      'apks': [],
      'documents': [],
      'compressed': [],
    };

    final params = await receivePort.first as List;
    final dirPath = params[0] as String;
    final resultSendPort = params[1] as SendPort;

    try {
      final dir = Directory(dirPath);
      final files = dir.list(recursive: false, followLinks: false);

      await for (final file in files) {
        if (file.path.contains('/0/Android')) continue;
        if (file is Directory) {
          await for (final subFile
              in file.list(recursive: true, followLinks: false)) {
            final ext = subFile.path.split('.').last.toLowerCase();
            extensions.forEach((key, value) {
              if (value.contains(ext)) {
                data[key]!.add(subFile);
              }
            });
          }
        }
        if (file is! File) {
          final ext = file.path.split('.').last.toLowerCase();
          extensions.forEach((key, value) {
            if (value.contains(ext)) {
              data[key]!.add(file);
            }
          });
        }
      }
      log('Data loaded.   data: $data');

      resultSendPort.send(data);
    } catch (e) {
      log('Error in isolate: $e');
      resultSendPort.send(data);
    } finally {
      receivePort.close();
    }
  }

  FutureOr<void> _deleteFile(
      DeleteQuickAccessFile event, Emitter<QuickAccessState> emit) async {
    final files = state
        .getFiles(event.type)
        .where((file) => !event.files.contains(file))
        .toList();

    emit(state.copyWith(
      apks: event.type == 'apks' ? files : null,
      images: event.type == 'images' ? files : null,
      videos: event.type == 'videos' ? files : null,
      audios: event.type == 'audios' ? files : null,
      documents: event.type == 'documents' ? files : null,
      compressedFiles: event.type == 'compressedFiles' ? files : null,
    ));

    final result =
        await _deleteFileUseCase(DeleteFileParms(files: event.files));
    result.fold((error) => emit(state.copyWith(error: error.message)), (_) {});
  }
}
