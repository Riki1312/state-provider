import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:state_provider/state_provider.dart';

typedef Emitter<T> = void Function(T state);
typedef Action<E, T> = FutureOr<void> Function(
  E event,
  Emitter<T> emit,
);

typedef Handler<T> = Future<T> Function(T event);
typedef EventTransformer<E> = Stream<E> Function(
  Stream<E> source,
  Handler<E> handler,
);

EventTransformer<E> concurrent<E>() {
  return (source, handler) => source.concurrentAsyncMap(handler);
}

EventTransformer<E> sequential<E>() {
  return (source, handler) => source.asyncMap(handler);
}

EventTransformer<E> droppable<E>() {
  return (source, handler) => source.asyncMapSample(handler);
}

EventTransformer<E> debounceSequential<E>(
  Duration duration, {
  bool leading = false,
  bool trailing = true,
}) {
  return (source, handler) => source
      .debounce(duration, leading: leading, trailing: trailing)
      .asyncMap(handler);
}

class StateBloc<E, T> extends StateValue<T> {
  StateBloc(
    T initialValue, {
    EventTransformer<E?>? defaultTransformer,
  }) : super(initialValue) {
    _defaultTransformer = defaultTransformer ?? concurrent();
  }

  final StateValue<E?> _events = StateValue(null);
  late final EventTransformer<E?> _defaultTransformer;

  T get state => value;

  void add(E event) => _events.value = event;

  void on<S extends E>(
    Action<E, T> action, {
    EventTransformer<E?>? transformer,
  }) {
    final source = (transformer ?? _defaultTransformer)(
      _events.stream.where((event) => event is S),
      (event) async {
        if (event != null) {
          await action(event, (T state) => value = state);
        }
        return event;
      },
    );

    addSource(source, onData: (_) {});
  }
}

class BlocProvider<B extends StateBloc> extends InheritedNotifier {
  const BlocProvider({
    Key? key,
    required this.bloc,
    required super.child,
  }) : super(key: key, notifier: bloc);

  final B bloc;

  static B of<B extends StateBloc>(
    BuildContext context, {
    bool listen = true,
  }) {
    final inherited = listen
        ? context.dependOnInheritedWidgetOfExactType<BlocProvider<B>>()
        : context.findAncestorWidgetOfExactType<BlocProvider<B>>();
    if (inherited == null) {
      throw StateNotFoundException(B.runtimeType, context.widget.runtimeType);
    }

    return inherited.bloc;
  }
}

class BlocBuilder<B extends StateBloc, T> extends StatelessWidget {
  const BlocBuilder({
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  final Widget Function(BuildContext context, T state, Widget? child) builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final bloc = context.bloc<B>();
    return AnimatedBuilder(
      animation: bloc,
      builder: (context, child) => builder(context, bloc.state, child),
      child: child,
    );
  }
}

extension BlocContext on BuildContext {
  B bloc<B extends StateBloc>() => BlocProvider.of<B>(this, listen: false);
}
