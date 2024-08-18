import 'package:filemanager/dependency.dart';
import 'package:filemanager/presentation/bloc/file_manager/file_manager_bloc.dart';
import 'package:filemanager/presentation/bloc/quick_access/quick_access_bloc.dart';
import 'package:filemanager/presentation/bloc/search/search_bloc.dart';
import 'package:filemanager/presentation/bloc/selected_item/selected_items_cubit.dart';
import 'package:filemanager/presentation/screen/file_manager_screen.dart';
import 'package:filemanager/presentation/screen/home_screen.dart';
import 'package:filemanager/presentation/screen/quick_access_screen.dart';
import 'package:filemanager/presentation/screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initDependency();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => serviceLocator<QuickAccessBloc>()),
        BlocProvider(create: (context) => serviceLocator<FileManagerBloc>()),
        BlocProvider(create: (context) => serviceLocator<SearchBloc>()),
        BlocProvider(create: (context) => serviceLocator<SelectedItemsCubit>()),
      ],
      child: MaterialApp(
          routes: AppRouter.routes,
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            appBarTheme: AppBarTheme(
              foregroundColor: Colors.black.withOpacity(0.99),
              color: Colors.transparent,
              elevation: 0,
            ),
            scaffoldBackgroundColor: const Color.fromARGB(255, 245, 247, 250),
          )),
    );
  }
}

class Routes {
  static const String home = '/';
  static const String quickAccess = '/quick-access';
  static const String fileManager = '/file-manager';
  static const String search = '/search';
}

class AppRouter {
  static final routes = <String, WidgetBuilder>{
    Routes.home: (context) => const HomeScreen(),
    Routes.quickAccess: (context) {
      final data = ModalRoute.of(context)!.settings.arguments as List<String>;
      final title = data[0];
      final type = data[1];
      return QuickAccessScreen(
        title: title,
        type: type,
      );
    },
    Routes.fileManager: (context) {
      final home = ModalRoute.of(context)!.settings.arguments as String?;

      return FileManagerScreen(home: home);
    },
    Routes.search: (context) {
      final data = ModalRoute.of(context)!.settings.arguments as String?;
      final title = data;
      return SearchScreen(directory: title);
    },
  };
}
