library state_provider;

import 'package:flutter/widgets.dart';

/// Provides a state [data] to its descendants Widget.
///
/// Descendants can access and listen to the state using
/// [StateProvider.of] or through `context.watch` and `context.read`.
///
/// The state object must extends [Listenable] or a class that extends
/// [Listenable], for example [ValueNotifier] and [ChangeNotifier].
class StateProvider<T extends Listenable> extends StatefulWidget {
  const StateProvider({
    Key? key,
    required this.data,
    required this.child,
  }) : super(key: key);

  /// The state object.
  final T data;

  /// The descendant Widget.
  final Widget child;

  @override
  State<StateProvider> createState() => _StateProviderState<T>();

  /// Returns the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// Use [listen] to listen to the state changes.
  ///
  /// If the [StateProvider] is not found, throws a [StateProviderNotFound] error.
  static T of<T extends Listenable>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inherited = listen
        ? context
            .dependOnInheritedWidgetOfExactType<_InheritedStateProvider<T>>()
        : context.findAncestorWidgetOfExactType<_InheritedStateProvider<T>>();

    if (inherited == null) {
      throw StateProviderNotFound(T.runtimeType, context.widget.runtimeType);
    }
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

/// The [Exception] that will be thrown if [StateProvider.of] fails to
/// find a [StateProvider] as an ancestor of the [BuildContext] used.
class StateProviderNotFound implements Exception {
  /// Create a ProviderNotFound error.
  StateProviderNotFound(
    this.stateType,
    this.widgetType,
  );

  /// Type of the state being retrieved.
  final Type stateType;

  /// Type of the Widget requesting the state.
  final Type widgetType;

  @override
  String toString() {
    return '''
Failed to find a StateProvider<$stateType> ancestor above $widgetType Widget.
This can happen if the context you used comes from a Widget above the StateProvider
or from the same Widget as that whose StateProvider is sought.
''';
  }
}

/// Extension on [BuildContext] to simplify access to a [StateProvider].
extension StateContext on BuildContext {
  /// Retrieve the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// As the opposite of [watch], this will not rebuild
  /// the Widget when the state notifies changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context, listen: false)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateProviderNotFound] error.
  T read<T extends Listenable>() {
    return StateProvider.of<T>(this, listen: false);
  }

  /// Retrieve and listen to the state of the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// As the opposite of [read], this will rebuild
  /// the Widget when the state notifies changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateProviderNotFound] error.
  T watch<T extends Listenable>() {
    return StateProvider.of<T>(this);
  }
}
