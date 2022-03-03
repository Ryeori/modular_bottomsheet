library modular_bottomsheet;

import 'package:flutter/material.dart';

void showModularBottomSheet({
  required BuildContext context,
  required Widget headerWidget,
  required Widget bodyWidget,
  bool upToStatusBar = true,
  double? maxHeight,
}) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return ModularBottomSheet(
          headerWidget: headerWidget,
          bodyWidget: bodyWidget,
          parentContext: context,
          upToStatusBar: upToStatusBar,
          maxHeigth: maxHeight ?? MediaQuery.of(context).size.height,
        );
      });
}

class ModularBottomSheet extends StatefulWidget {
  final Widget headerWidget;
  final Widget bodyWidget;
  final BuildContext parentContext;
  final bool upToStatusBar;
  final ScrollController? controller;
  final double maxHeigth;
  const ModularBottomSheet(
      {Key? key,
      required this.headerWidget,
      required this.bodyWidget,
      required this.parentContext,
      required this.upToStatusBar,
      this.controller,
      required this.maxHeigth})
      : super(key: key);

  @override
  State<ModularBottomSheet> createState() => _ScrollableModularBottomSheet();
}

class _ScrollableModularBottomSheet extends State<ModularBottomSheet> {
  //TODO: Rename fields
  late final Size screenSize;
  double headerHeightScreenRatio = 0.1;
  //TODO: try to find a way to remove
  double bodyHeightScreenRatio = 0.1;
  double headerHeight = 0;
  GlobalKey headerKey = GlobalKey();
  GlobalKey bodyKey = GlobalKey();

  double get getHeaderHeightFraction =>
      (headerKey.currentContext?.size?.height ?? 0) / screenSize.height;

  double get getBodyHeightFraction =>
      (bodyKey.currentContext?.size?.height ?? 0) / widget.maxHeigth;

  double get getMaxChildrenHeightFraction =>
      (bodyHeightScreenRatio + headerHeightScreenRatio).clamp(0, 1);

  double get getMaxHeightFraction {
    if (getMaxChildrenHeightFraction == 1 && widget.upToStatusBar) {
      return widget.maxHeigth / screenSize.height -
          (MediaQuery.of(widget.parentContext).padding.top / screenSize.height);
    } else {
      return getMaxChildrenHeightFraction;
    }
  }

  @override
  void initState() {
    initialSizeCalculations();
    super.initState();
  }

  void initialSizeCalculations() {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      screenSize = MediaQuery.of(context).size;
      headerHeight = (headerKey.currentContext?.size?.height ?? 0) +
          (MediaQuery.of(widget.parentContext).padding.top);
      headerHeightScreenRatio = getHeaderHeightFraction;
      bodyHeightScreenRatio = getBodyHeightFraction;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      //TODO: Might be refactored
      minChildSize: 0.001,
      initialChildSize: headerHeightScreenRatio,
      maxChildSize: getMaxHeightFraction,
      snap: true,
      //TODO: Add custom snap sizes
      snapSizes: [headerHeightScreenRatio, getMaxHeightFraction],
      builder: (context, scrollController) {
        return ListView(
          shrinkWrap: true,
          controller: scrollController,
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                key: headerKey,
                child: widget.headerWidget),
            ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: widget.maxHeigth - headerHeight),
              child: SizedBox(key: bodyKey, child: widget.bodyWidget),
            )
          ],
        );
      },
    );
  }
}
