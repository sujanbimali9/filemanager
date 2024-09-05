part of 'quick_access_bloc.dart';

class QuickAccessState extends Equatable {
  final bool isLoading;
  final List<FileSystemEntity> images;
  final List<FileSystemEntity> videos;
  final List<FileSystemEntity> audios;
  final List<FileSystemEntity> apks;
  final List<FileSystemEntity> documents;
  final List<FileSystemEntity> compressedFiles;
  final String? error;

  Future<String> get getRootDir async {
    if (Platform.isLinux) {
      return Platform.environment['HOME'] ?? '';
    }
    if (Platform.isIOS) {
      return '/';
    }

    if (Platform.isAndroid) {
      final applicationDirectory = await getExternalStorageDirectory();
      return applicationDirectory!.path
          .replaceAll('/Android/data/com.example.filemanager/files', '');
    }
    return '/';
  }

  List<FileSystemEntity> getFiles(String type) {
    switch (type) {
      case 'images':
        return images;
      case 'videos':
        return videos;
      case 'audios':
        return audios;
      case 'apps':
        return apks;
      case 'documents':
        return documents;
      case 'compressedFiles':
        return compressedFiles;
      default:
        return [];
    }
  }

  const QuickAccessState({
    required this.isLoading,
    required this.images,
    required this.videos,
    required this.apks,
    required this.documents,
    required this.compressedFiles,
    required this.audios,
    this.error,
  });

  @override
  List<Object> get props => [
        isLoading,
        images,
        videos,
        apks,
        documents,
        compressedFiles,
      ];
  factory QuickAccessState.initial() {
    return const QuickAccessState(
      isLoading: true,
      images: [],
      videos: [],
      apks: [],
      documents: [],
      compressedFiles: [],
      audios: [],
    );
  }

  QuickAccessState copyWith({
    bool? isLoading,
    List<FileSystemEntity>? images,
    List<FileSystemEntity>? videos,
    List<FileSystemEntity>? audios,
    List<FileSystemEntity>? apks,
    List<FileSystemEntity>? documents,
    List<FileSystemEntity>? compressedFiles,
    String? error,
  }) {
    return QuickAccessState(
      isLoading: isLoading ?? this.isLoading,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      audios: audios ?? this.audios,
      apks: apks ?? this.apks,
      documents: documents ?? this.documents,
      compressedFiles: compressedFiles ?? this.compressedFiles,
      error: error,
    );
  }
}
