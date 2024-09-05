import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:filemanager/main.dart';
import 'package:filemanager/presentation/screen/recent_files.dart';
import 'package:filemanager/presentation/widgets/quick_access.dart';
import 'package:filemanager/presentation/widgets/search_field.dart';
import 'package:filemanager/presentation/widgets/storage_container.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:storage_utility/storage_utility.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DraggableScrollableController dragController;
  @override
  void initState() {
    _handlePermission(context);
    dragController = DraggableScrollableController();
    super.initState();
  }

  void _handlePermission(BuildContext context) async {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;

    if (deviceInfo.version.sdkInt >= 32) {
      final storageStatus = await Permission.manageExternalStorage.status;
      if (storageStatus.isGranted) {
        return;
      } else if (storageStatus.isPermanentlyDenied) {
        if (context.mounted) {
          permissionDeniedDialog(context);
        }
      } else {
        await Permission.manageExternalStorage.request();
        if (context.mounted) {
          return _handlePermission(context);
        }
      }
      return;
    }

    final storageStatus = await Permission.storage.status;
    if (storageStatus.isGranted) {
      return;
    } else if (storageStatus.isPermanentlyDenied) {
      if (context.mounted) {
        permissionDeniedDialog(context);
      }
    } else {
      await Permission.manageExternalStorage.request();
      if (context.mounted) {
        return _handlePermission(context);
      }
    }
    return;
  }

  Future<dynamic> permissionDeniedDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content:
              const Text('Please grant the permission to access the storage.'),
          actions: [
            TextButton(
              onPressed: () {
                exit(0); // Terminate the app (use with caution)
              },
              child: const Text('Close App'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // Open app settings
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    dragController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const SearchField(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: FutureBuilder(
                            future:
                                Future.wait([getFreeBytes(), getTotalBytes()]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const StorageContainer(
                                  totalStorage: 0,
                                  usedStorage: 0,
                                  icon: Icons.phone_android_rounded,
                                  title: 'InternalStorage',
                                  onTap: null,
                                  width: double.infinity,
                                );
                              }
                              final storageSpace = snapshot.data!;
                              return StorageContainer(
                                totalStorage: storageSpace[1],
                                usedStorage: storageSpace[1] - storageSpace[0],
                                icon: Icons.phone_android_rounded,
                                title: 'InternalStorage',
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, Routes.fileManager,
                                      arguments: '/storage/emulated/0/');
                                },
                                width: double.infinity,
                              );
                            }),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StorageContainer(
                          totalStorage: 0,
                          usedStorage: 0,
                          icon: Icons.sd_card_outlined,
                          title: 'Micro SD',
                          onTap: () {},
                          width: double.infinity,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 300, maxWidth: 450),
                      child: GridView.builder(
                        itemCount: quickAccessData.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          childAspectRatio: 9 / 11,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) => QuickAccess(
                          quickAccessData: quickAccessData[index],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                ],
              ),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 0.25),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return DraggableScrollableSheet(
                initialChildSize: value,
                minChildSize: value,
                expand: true,
                shouldCloseOnMinExtent: false,
                controller: dragController,
                snap: true,
                builder: (context, controller) {
                  return AnimatedBuilder(
                    animation: dragController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(dragController.isAttached
                                  ? 30 - dragController.size * 30
                                  : 30),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ]),
                        padding: const EdgeInsets.all(20),
                        child: child!,
                      );
                    },
                    child: RecentFiles(
                      files: const {},
                      scrollController: controller,
                      dragController: dragController,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

final quickAccessData = [
  QuickAccessData(
    title: 'Pictures',
    icon: 'assets/icons/image.png',
    color: Colors.blue,
    routeName: Routes.quickAccess,
    routeArguments: ['Pictures', 'images'],
  ),
  QuickAccessData(
    title: 'Videos',
    icon: 'assets/icons/video.png',
    color: Colors.red,
    routeName: Routes.quickAccess,
    routeArguments: ['Videos', 'videos'],
  ),
  QuickAccessData(
    title: 'Music',
    icon: 'assets/icons/audio.png',
    color: Colors.yellow,
    routeName: Routes.quickAccess,
    routeArguments: ['Audio', 'audios'],
  ),
  QuickAccessData(
    title: 'Apps',
    icon: 'assets/icons/application.png',
    color: Colors.pink,
    routeName: Routes.quickAccess,
    routeArguments: ['Apps', 'apps'],
  ),
  QuickAccessData(
    title: 'Documents',
    icon: 'assets/icons/document.png',
    color: Colors.lightBlueAccent,
    routeName: Routes.quickAccess,
    routeArguments: ['Documents', 'documents'],
  ),
  QuickAccessData(
    title: 'Downloads',
    icon: 'assets/icons/download.png',
    color: Colors.green,
    routeName: Routes.fileManager,
    routeArguments: '/storage/emulated/0/Download/',
  ),
  QuickAccessData(
    title: 'Zip Files',
    icon: 'assets/icons/compress.png',
    color: Colors.grey,
    routeName: Routes.quickAccess,
    routeArguments: ['Compressed', 'compressed'],
  ),
  QuickAccessData(
    title: 'Add',
    icon: Icons.add,
    isAssetImage: false,
    color: Colors.white,
    routeName: Routes.quickAccess,
    routeArguments: 'downloads',
  ),
];

class QuickAccessData {
  final String title;
  final dynamic icon;
  final String routeName;
  final dynamic routeArguments;
  final bool isAssetImage;
  final Color color;

  QuickAccessData({
    required this.title,
    required this.icon,
    required this.color,
    required this.routeName,
    this.routeArguments,
    this.isAssetImage = true,
  });
}
