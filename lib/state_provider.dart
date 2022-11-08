/// A super simple state management library for Flutter.
library state_provider;

import 'dart:async';

import 'package:flutter/widgets.dart';

/// Contains the immutable value of a state.
class StateValue<T> implements Listenable {
  /// Creates a [StateValue] with the given [initialValue].
  ///
  /// [persistent] indicates that the state should not be closed
  /// automatically when all its listeners are removed.
  StateValue(
    T initialValue, {
    bool persistent = false,
  })  : _value = initialValue,
        _persistent = persistent;

  T _value;

  bool _accessed = false;

  final bool _persistent;

  final _streamController = StreamController<T>.broadcast();
  final _subscriptions = <VoidCallback, StreamSubscription<T>>{};
  final _sourceSubscriptions = <Stream, StreamSubscription>{};

  /// The current value of the state.
  ///
  /// When this value is set to a new object,
  /// the widgets listening to this state will be rebuilt.
  ///
  /// The value object should be immutable.
  T get value {
    if (!_accessed) {
      _accessed = true;
      onFirstAccess();
    }
    return _value;
  }

  set value(T newValue) {
    if (!shouldUpdate(newValue)) return;

    _value = newValue;
    _streamController.add(newValue);
  }

  /// The [Stream] of state values.
  Stream<T> get stream => _streamController.stream;

  /// Close the [stream] and release the resources.
  ///
  /// This also closes all subscriptions from sources and listeners.
  Future<void> close() async {
    if (_streamController.isClosed) return;

    await onClose();
    // Close sources subscriptions.
    for (var s in _sourceSubscriptions.values) {
      await s.cancel();
    }
    _sourceSubscriptions.clear();
    // Close listeners subscriptions.
    for (var s in _subscriptions.values) {
      await s.cancel();
    }
    _subscriptions.clear();
    await _streamController.close();
  }

  @override
  void addListener(VoidCallback listener) {
    final subscription = _streamController.stream.listen((_) => listener());
    _subscriptions[listener] = subscription;
  }

  @override
  void removeListener(VoidCallback listener) {
    _subscriptions.remove(listener)?.cancel();
    // Close the stream if there is no listener and the state is not persistent.
    if (!_streamController.hasListener && !_persistent) {
      close();
    }
  }

  /// Add a source [Stream] to this state.
  void addSource<S>(
    Stream<S> stream, {
    required FutureOr<void> Function(S data) onData,
  }) {
    final subscription = stream.asyncMap((event) async {
      await onData(event);
      return event;
    }).listen((_) {});
    _sourceSubscriptions[stream] = subscription;
  }

  /// Remove a previously added source [Stream] from this state.
  void removeSource<S>(Stream<S> stream) {
    _sourceSubscriptions.remove(stream)?.cancel();
  }

  /// Function used to determine if the state value should be updated.
  ///
  /// This use the [==] operator by default,
  /// can be overridden to perform some custom logic.
  bool shouldUpdate(T newValue) {
    return value != newValue;
  }

  /// Function called the first time the state [value] is accessed.
  ///
  /// This can be overridden to perform some initial state setup.
  /// For example, to load data from a remote source.
  Future<void> onFirstAccess() async {}

  /// Function called before the state is closed.
  ///
  /// This can be overridden to perform some cleanup.
  /// For example, to cancel a subscription.
  Future<void> onClose() async {}
}

/// Provides a [state] to its descendants widgets.
///
/// Descendants can access and listen to the state using
/// [StateProvider.of] or through `context.watch` and `context.read`.
///
/// The state object must extends [StateValue].
class StateProvider<T extends StateValue> extends InheritedNotifier {
  /// Creates a [StateProvider] with the given [state].
  const StateProvider({
    Key? key,
    required this.state,
    required super.child,
  }) : super(key: key, notifier: state);

  /// The state object.
  final T state;

  /// Retrieve and listen to the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// Set [listen] to `false` to not rebuild
  /// the widget when the state value changes.
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

  /// Type of the widget requesting the state.
  final Type widgetType;

  @override
  String toString() {
    return '''
Failed to find a StateProvider<$stateType> ancestor above $widgetType Widget.

This can happen if the context you used comes from a widget above the StateProvider
or from the same widget as that whose StateProvider is sought.
''';
  }
}

/// Extension on [BuildContext] to simplify access to a [StateProvider].
extension StateContext on BuildContext {
  /// Retrieve the state from the nearest [StateProvider]
  /// ancestor that holds a state of type [T].
  ///
  /// As the opposite of [watch], this will not rebuild
  /// the widget when the state value changes.
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
  /// the widget when the state value changes.
  ///
  /// This is a shorthand for `StateProvider.of<T>(context)`.
  ///
  /// If the [StateProvider] is not found, throws a [StateNotFoundException].
  T watch<T extends StateValue>() {
    return StateProvider.of<T>(this);
  }
}
