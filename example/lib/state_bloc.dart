import 'package:flutter/widgets.dart';
import 'package:state_provider/state_provider.dart';

typedef EmitFunction<T> = void Function(T state);
typedef ActionFunction<E, T> = void Function(E event, EmitFunction<T> emit);

class StateBloc<E, T> extends StateValue<T> {
  StateBloc(T initialValue) : super(initialValue) {
    addSource(_events.stream, onData: _onData);
  }

  final _events = StateValue<E?>(null);
  final _actions = <Type, ActionFunction<E, T>>{};

  T get state => value;

  void add(E event) => _events.value = event;

  void on<S extends E>(ActionFunction<E, T> action) {
    _actions[S] = action;
  }

  void _onData(E? event) {
    if (event == null) {
      return;
    }

    final action = _actions[event.runtimeType];
    if (action != null) {
      action(event, (T state) => value = state);
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
