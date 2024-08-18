import 'package:filemanager/presentation/screen/home_screen.dart';
import 'package:flutter/material.dart';

class QuickAccess extends StatelessWidget {
  const QuickAccess({
    super.key,
    required this.quickAccessData,
  });

  final QuickAccessData quickAccessData;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                quickAccessData.routeName,
                arguments: quickAccessData.routeArguments,
              );
            },
            child: Container(
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 50,
                    maxWidth: 50,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: quickAccessData.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: quickAccessData.isAssetImage
                      ? Image.asset(
                          quickAccessData.icon,
                          color: Colors.white,
                          width: 25,
                          height: 25,
                        )
                      : Icon(
                          quickAccessData.icon,
                          size: 25,
                          color: Colors.grey,
                        ),
                )),
          ),
        ),
        Text(
          quickAccessData.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
