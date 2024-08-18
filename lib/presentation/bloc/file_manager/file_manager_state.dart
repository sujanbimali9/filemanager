part of 'file_manager_bloc.dart';

final class FileManagerState extends Equatable {
  final List<FileSystemEntity> files;
  final FileSystemEntity? currentDirectory;
  final SortBy _sortBy;
  final bool isLoading;
  final String? error;
  final bool _showHidden;
  final String rootDirectory;

  bool get hasParentDirectory => currentDirectory?.parent != null;
  bool get hasFiles => files.isNotEmpty;
  bool get hasDirectories => files.any((file) => file.isDirectory);
  SortBy get sortBy => _sortBy;
  bool get showHidden => _showHidden;

  bool get isRoot {
    final normalizedCurrentPath =
        currentDirectory?.path.replaceAll(RegExp(r'/+$'), '');
    final normalizedRootPath = rootDirectory.replaceAll(RegExp(r'/+$'), '');

    return normalizedCurrentPath == normalizedRootPath;
  }

  String getReadablePath(int maxLetters) {
    if (currentDirectory == null) return '';

    final knownPaths = <String, String>{
      Platform.environment['HOME'] ?? 'unknown':
          'Home/${Platform.environment['USERNAME']}',
      '/storage/emulated/0': 'Internal',
      '/storage/external/emulated/0': 'External',
      '/storage/[sd_card_name]': 'Micro SD',
      '/Documents': 'Documents',
      '/Library': 'Library Storage',
      '/Caches': 'Cache Storage',
      '/tmp': 'Temporary Storage',
    };

    final String fullPath = currentDirectory!.path;

    log('fullPath: $fullPath');
    String readablePath = fullPath;

    for (var entry in knownPaths.entries) {
      if (fullPath.startsWith(entry.key)) {
        readablePath = readablePath.replaceFirst(entry.key, entry.value);
        break;
      }
    }

    final readableSegments = readablePath.split(Platform.pathSeparator)
      ..remove('');

    if (readablePath.length > maxLetters) {
      final lastSegments = readableSegments
          .sublist(readableSegments.length - (maxLetters ~/ 10));
      return ['...', ...lastSegments].join('/');
    }

    return readableSegments.join('/');
  }

  const FileManagerState({
    required this.files,
    required this.currentDirectory,
    required this.rootDirectory,
    this.isLoading = false,
    this.error,
    SortBy sortBy = SortBy.name,
    bool showHidden = false,
  })  : _sortBy = sortBy,
        _showHidden = showHidden;

  factory FileManagerState.initial() => const FileManagerState(
        files: [],
        currentDirectory: null,
        rootDirectory: '',
        isLoading: true,
      );

  @override
  List<Object> get props => [files, currentDirectory ?? '', rootDirectory];

  FileManagerState copyWith({
    List<FileSystemEntity>? files,
    FileSystemEntity? currentDirectory,
    String? error,
    bool? isLoading,
    SortBy? sortBy,
    bool? showHidden,
    String? rootDirectory,
  }) {
    return FileManagerState(
      files: files ?? this.files,
      currentDirectory: currentDirectory ?? this.currentDirectory,
      rootDirectory: rootDirectory ?? this.rootDirectory,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      sortBy: sortBy ?? _sortBy,
      showHidden: showHidden ?? _showHidden,
    );
  }
}

extension FileSystemEntityX on FileSystemEntity {
  String get name => path.split('/').last;
  bool get isDirectory => path is Directory;
  bool get isFile => path is File;
}

enum SortBy { name, date, size }
