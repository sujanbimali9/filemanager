import 'package:flutter/material.dart';

class AnimatedBottomBuilder extends StatelessWidget {
  final bool firstChild;
  final Widget child1;
  final Widget? child2;
  const AnimatedBottomBuilder({
    super.key,
    required this.firstChild,
    required this.child1,
    this.child2,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
        offset: firstChild
            ? const Offset(0, 0)
            : child2 != null
                ? const Offset(0, 0)
                : const Offset(0, 1),
        duration: const Duration(milliseconds: 300),
        child: firstChild
            ? Container(
                height: 70,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: child1,
              )
            : child2 != null
                ? Container(
                    height: 70,
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: child2,
                  )
                : const SizedBox.shrink());
  }
}
