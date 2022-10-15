library state_provider;

import 'package:flutter/widgets.dart';

class StateProvider<T extends Listenable> extends StatefulWidget {
  const StateProvider({
    Key? key,
    required this.data,
    required this.child,
  }) : super(key: key);

  final T data;

  final Widget child;

  @override
  State<StateProvider> createState() => _StateProviderState<T>();

  static T of<T extends Listenable>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inherited = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_InheritedStateProvider<T>>()!
        : context.findAncestorWidgetOfExactType<_InheritedStateProvider<T>>()!;
    return inherited.data;
  }
}

class _StateProviderState<T extends Listenable> extends State<StateProvider> {
  @override
  Widget build(BuildContext context) {
    return _InheritedStateProvider<T>(
      data: widget.data as T,
      child: widget.child,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.data.addListener(_update);
  }

  @override
  void dispose() {
    widget.data.removeListener(_update);
    super.dispose();
  }

  @override
  void didUpdateWidget(StateProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      oldWidget.data.removeListener(_update);
      widget.data.addListener(_update);
    }
  }

  void _update() {
    setState(() {});
  }
}

class _InheritedStateProvider<T extends Listenable> extends InheritedWidget {
  const _InheritedStateProvider({
    Key? key,
    required this.data,
    required child,
  }) : super(key: key, child: child);

  final T data;

  @override
  bool updateShouldNotify(_InheritedStateProvider oldWidget) {
    return !identical(oldWidget, this);
  }
}

extension StateContext on BuildContext {
  T read<T extends Listenable>() {
    return StateProvider.of<T>(this, listen: false);
  }

  T watch<T extends Listenable>() {
    return StateProvider.of<T>(this);
  }
}
