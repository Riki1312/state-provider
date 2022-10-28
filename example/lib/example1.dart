import 'dart:async';

import 'package:flutter/material.dart';
import 'package:state_provider/state_provider.dart';

class CounterState extends StateValue<int> {
  CounterState() : super(0);

  void increment() {
    value++;
  }
}

class ListState extends StateValue<List<String>> {
  ListState(CounterState counterState) : super([]) {
    sub = counterState.stream.where((number) => number.isOdd).listen((number) {
      value = [...value, "Odd: $number"];
    });
  }

  StreamSubscription? sub;

  @override
  Future<void> onClose() async => sub?.cancel();
}

//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build MyApp");

    final counter = CounterState();

    return StateProvider(
      state: counter,
      child: StateProvider(
        state: ListState(counter),
        // state: StateValue<int>(1),
        child: const MaterialApp(
          title: 'Example',
          home: MyHomePage(),
        ),
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

    return Column(
      children: [
        Builder(
          builder: (c) => Text('Count: ${c.watch<CounterState>().value}'),
        ),
        Builder(
          builder: (c) => Text('List: ${c.watch<ListState>().value}'),
        ),
      ],
    );
  }
}

class MyHomeButton extends StatelessWidget {
  const MyHomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build MyHomeButton");

    return Center(
      child: ElevatedButton(
        onPressed: () {
          context.read<CounterState>().increment();
        },
        child: const Text('Button'),
      ),
    );
  }
}
