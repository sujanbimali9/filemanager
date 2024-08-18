import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchEvent>((event, emit) {});
    on<SearchFile>(_searchFile);
    on<SearchClear>(_clearSearch);
  }

  FutureOr<void> _searchFile(
      SearchFile event, Emitter<SearchState> emit) async {
    emit(SearchLoading());

    final receivePort = ReceivePort();
    final isolate =
        await Isolate.spawn(_searchFileIsolate, receivePort.sendPort);

    final sendPort = await receivePort.first as SendPort;
    final resultPort = ReceivePort();
    final directory = event.directory ??
        Platform.environment['HOME'] ??
        '/storage/emulated/0';
    sendPort.send([directory, event.query, resultPort.sendPort]);

    await for (final partialResults in resultPort) {
      if (partialResults is SearchException) {
        emit(SearchError(partialResults.toString()));
        break;
      } else if (partialResults == null) {
        break;
      }
      final results = partialResults as Set<FileSystemEntity>;
      emit(SearchLoaded(results));
    }

    receivePort.close();
    resultPort.close();
    isolate.kill(priority: Isolate.immediate);
  }

  static void _searchFileIsolate(SendPort sendPort) async {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    final data = await receivePort.first as List;
    final directory = data[0] as String;
    final query = data[1] as String;
    final responsePort = data[2] as SendPort;

    final searchResults = <FileSystemEntity>{};

    try {
      final files =
          Directory(directory).list(recursive: true, followLinks: false);
      await for (final file in files) {
        final fileName = file.path.split('/').last.toLowerCase();
        if (fileName.contains(query.toLowerCase())) {
          searchResults.add(file);
          responsePort.send(searchResults);
        }
      }
      responsePort.send(null);
    } catch (e) {
      responsePort.send(SearchException(e.toString()));
    } finally {
      receivePort.close();
    }
  }

  FutureOr<void> _clearSearch(
      SearchClear event, Emitter<SearchState> emit) async {
    emit(SearchInitial());
  }
}

class SearchException implements Exception {
  final String message;

  SearchException(this.message);

  @override
  String toString() => 'SearchException($message)';
}
