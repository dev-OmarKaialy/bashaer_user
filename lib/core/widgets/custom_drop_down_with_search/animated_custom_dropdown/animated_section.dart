part of 'custom_dropdown.dart';

class AnimatedSection extends StatefulWidget {
  final bool expand;
  final VoidCallback animationDismissed;
  final Function? onComplete;
  final Widget child;
  final double axisAlignment;
  const AnimatedSection({
    super.key,
    this.expand = false,
    this.onComplete,
    required this.animationDismissed,
    required this.child,
    required this.axisAlignment,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection> with SingleTickerProviderStateMixin {
  late AnimationController animController;
  late Animation<double> animation;
  bool isAdjusted = false;
  @override
  void initState() {
    super.initState();
    prepareAnimations();
    runExpand();
  }

  void prepareAnimations() {
    animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          widget.animationDismissed();
        }
      });

    animation = CurvedAnimation(parent: animController, curve: Curves.linearToEaseOut);
  }

  void runExpand() {
    if (widget.expand) {
      animController.forward();
    } else {
      animController.reverse();
    }
    if (animController.isCompleted) {}
  }

  @override
  void didUpdateWidget(AnimatedSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    runExpand();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        axisAlignment: widget.axisAlignment,

        sizeFactor: animation,
        child: widget.child,
      ),
    );
  }
}
