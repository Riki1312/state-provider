/// A simple-stupid state management library for Flutter.
library state_provider;

import 'package:flutter/widgets.dart';

class StateValue<T> {
  StateValue(T initialValue) : _notifier = ValueNotifier<T>(initialValue);

  final ValueNotifier<T> _notifier;

  T get value => _notifier.value;
  set value(T newValue) => _notifier.value = newValue;
}

class StateData<T> {
  StateData(T initialData) : _notifier = ValueNotifier<T>(initialData);

  final ValueNotifier<T> _notifier;

  T get value => _notifier.value;

  @protected
  void emit(T data) => _notifier.value = data;
}

/// Provides a state [data] to its descendants Widget.
///
/// Descendants can access and listen to the state using
/// [StateProvider.of] or through `context.watch` and `context.read`.
///
/// The state object must extends [StateData].
class StateProvider<T extends StateData> extends InheritedNotifier {
  StateProvider({
    Key? key,
    required this.data,
    required super.child,
  }) : super(key: key, notifier: data._notifier);

  /// The state object.
  final T data;

  /// Retrieve and listen to the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// Set [listen] to `false` to not rebuild
  /// the Widget when the state notifies changes.
  ///
  /// If the [StateProvider] is not found, throws a [StateProviderNotFound] error.
  static T of<T extends StateData>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<StateProvider<T>>()
        : context.findAncestorWidgetOfExactType<StateProvider<T>>();

    if (inherited == null) {
      throw StateProviderNotFound(T.runtimeType, context.widget.runtimeType);
    }
    return inherited.data;
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
  T read<T extends StateData>() {
    return StateProvider.of<T>(this, listen: false);
  }

  /// Retrieve and listen to the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// As the opposite of [read], this will rebuild
  /// the Widget when the state notifies changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateProviderNotFound] error.
  T watch<T extends StateData>() {
    return StateProvider.of<T>(this);
  }
}
