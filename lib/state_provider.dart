/// A simple-stupid state management library for Flutter.
library state_provider;

import 'package:flutter/widgets.dart';

/// Contains the immutable value of a state.
class StateValue<T> {
  /// Creates a [StateValue] with the given [initialValue].
  StateValue(T initialValue) : _notifier = ValueNotifier<T>(initialValue);

  final ValueNotifier<T> _notifier;

  /// The current value of the state.
  ///
  /// When this value is set to a new object,
  /// the Widgets listening to this state will be rebuilt.
  ///
  /// The value object should be immutable.
  T get value => _notifier.value;
  set value(T newValue) => _notifier.value = newValue;
}

/// Provides a [state] to its descendants Widget.
///
/// Descendants can access and listen to the state using
/// [StateProvider.of] or through `context.watch` and `context.read`.
///
/// The state object must extends [StateValue].
class StateProvider<T extends StateValue> extends InheritedNotifier {
  /// Creates a [StateProvider] with the given [state].
  StateProvider({
    Key? key,
    required this.state,
    required super.child,
  }) : super(key: key, notifier: state._notifier);

  /// The state object.
  final T state;

  /// Retrieve and listen to the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// Set [listen] to `false` to not rebuild
  /// the Widget when the state value changes.
  ///
  /// If the [StateProvider] is not found, throws a [StateNotFoundException].
  static T of<T extends StateValue>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<StateProvider<T>>()
        : context.findAncestorWidgetOfExactType<StateProvider<T>>();

    if (inherited == null) {
      throw StateNotFoundException(T.runtimeType, context.widget.runtimeType);
    }
    return inherited.state;
  }
}

/// The [Exception] that will be thrown if [StateProvider.of] fails to
/// find a [StateProvider] ancestor that holds a state of the specified type.
class StateNotFoundException implements Exception {
  StateNotFoundException(
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
  /// the Widget when the state value changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context, listen: false)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateNotFoundException].
  T read<T extends StateValue>() {
    return StateProvider.of<T>(this, listen: false);
  }

  /// Retrieve and listen to the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// As the opposite of [read], this will rebuild
  /// the Widget when the state value changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateNotFoundException].
  T watch<T extends StateValue>() {
    return StateProvider.of<T>(this);
  }
}
