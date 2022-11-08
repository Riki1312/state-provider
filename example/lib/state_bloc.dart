import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:state_provider/state_provider.dart';
import 'package:stream_transform/stream_transform.dart';

typedef Emitter<T> = void Function(T state);
typedef Action<E, T> = Future<void> Function(
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
    EventTransformer<E?>? transformer,
  }) : super(initialValue) {
    final source = (transformer ?? concurrent())(
      _events.stream,
      (event) async {
        await _onData(event);
        return event;
      },
    );

    addSource(source, onData: (_) {});
  }

  final _events = StateValue<E?>(null);
  final _actions = <Type, Action<E, T>>{};

  T get state => value;

  void add(E event) => _events.value = event;

  void on<S extends E>(Action<E, T> action) {
    _actions[S] = action;
  }

  Future<void> _onData(E? event) async {
    if (event == null) {
      return;
    }

    final action = _actions[event.runtimeType];
    if (action != null) {
      await action(event, (T state) => value = state);
    }
  }
}

class BlocProvider<E, T> extends StatelessWidget {
  const BlocProvider({
    required this.bloc,
    required this.child,
    Key? key,
  }) : super(key: key);

  final StateBloc<E, T> bloc;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StateProvider(state: bloc, child: child);
  }
}

class BlocBuilder<E, T> extends StatelessWidget {
  const BlocBuilder({required this.builder, Key? key}) : super(key: key);

  final Widget Function(BuildContext context, T state) builder;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final bloc = StateProvider.of<StateBloc<E, T>>(context);
      return builder(context, bloc.state);
    });
  }
}

extension BlocContext on BuildContext {
  StateBloc<E, T> bloc<E, T>() =>
      StateProvider.of<StateBloc<E, T>>(this, listen: false);
}
