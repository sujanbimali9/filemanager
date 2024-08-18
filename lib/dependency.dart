import 'package:filemanager/data/data_source/local_data_source.dart';
import 'package:filemanager/data/repository/local_repository_imp.dart';
import 'package:filemanager/domain/repository/local_repository.dart';
import 'package:filemanager/domain/usecase/compress_file.dart';
import 'package:filemanager/domain/usecase/copy_file.dart';
import 'package:filemanager/domain/usecase/create_directory.dart';
import 'package:filemanager/domain/usecase/delete_file.dart';
import 'package:filemanager/domain/usecase/extract_file.dart';
import 'package:filemanager/domain/usecase/move_file.dart';
import 'package:filemanager/domain/usecase/rename_file.dart';
import 'package:filemanager/domain/usecase/share_files.dart';
import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/bloc/quick_access/quick_access_bloc.dart';
import 'package:filemanager/presentation/bloc/search/search_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

void initDependency() {
  serviceLocator
    ..registerFactory<FileManagerLocalDataSource>(
        () => FileManagerLocalDataSourceImp())
    ..registerFactory<FileManagerLocalRepository>(
        () => FileManagerLocalRepositoryImp(serviceLocator()))
    ..registerFactory(() => MoveFileUseCase(serviceLocator()))
    ..registerFactory(() => CopyFileUseCase(serviceLocator()))
    ..registerFactory(() => DeleteFileUseCase(serviceLocator()))
    ..registerFactory(() => ExtractFileUseCase(serviceLocator()))
    ..registerFactory(() => RenameFileUseCase(serviceLocator()))
    ..registerFactory(() => CompressFileUseCase(serviceLocator()))
    ..registerFactory(() => CreateDirectoryUseCase(serviceLocator()))
    ..registerFactory(() => ShareFileUseCase(serviceLocator()))
    ..registerFactory(() => FileManagerBloc(
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
          serviceLocator(),
        ))
    ..registerFactory(() => SearchBloc())
    ..registerFactory(() => SelectedItemsCubit())
    ..registerFactory(() => QuickAccessBloc(serviceLocator()));
}
