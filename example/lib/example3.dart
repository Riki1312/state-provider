import 'package:flutter/material.dart';

import 'package:state_provider_example/state_bloc.dart';

abstract class CounterEvent {}

class CounterIncrement extends CounterEvent {}

class CounterDecrement extends CounterEvent {}

class CounterBloc extends StateBloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<CounterIncrement>(
      (event, emit) async {
        await Future.delayed(const Duration(seconds: 4));
        emit(state + 1);
      },
      transformer: concurrent(),
    );

    on<CounterDecrement>(
      (event, emit) async {
        await Future.delayed(const Duration(seconds: 4));
        emit(state - 1);
      },
      transformer: sequential(),
    );
  }
}

//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build MyApp");

    return BlocProvider(
      bloc: CounterBloc(),
      child: const MaterialApp(
        title: 'Example',
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build MyHomePage");

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: ListView(
        children: const [
          MyHomeText(),
          MyHomeButton(),
        ],
      ),
    );
  }
}

class MyHomeText extends StatelessWidget {
  const MyHomeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build MyHomeText");

    return BlocBuilder<CounterBloc, int>(
      builder: (context, state, _) {
        return Text("Counter: $state");
      },
    );
  }
}

class MyHomeButton extends StatelessWidget {
  const MyHomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build MyHomeButton");

    return Column(
      children: [
        ElevatedButton(
          onPressed: () => context.bloc<CounterBloc>().add(CounterIncrement()),
          child: const Text('Increment'),
        ),
        ElevatedButton(
          onPressed: () => context.bloc<CounterBloc>().add(CounterDecrement()),
          child: const Text('Decrement'),
        ),
      ],
    );
  }
}
