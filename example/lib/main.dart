import 'package:flutter/material.dart';

import 'package:state_provider/state_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build MyApp");

    return StateProvider(
      state: ListState(),
      // state: StateValue<int>(1),
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

    return Column(
      children: [
        Builder(
          builder: (context) {
            return Text('Count: ${context.watch<ListState>().value}');
            // return Text('Count: ${context.watch<StateValue<int>>().value}');
          },
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
          context.read<ListState>().increment();
          //context.read<StateValue<int>>().value++;
        },
        child: const Text('Button'),
      ),
    );
  }
}

//

class CounterState extends StateValue<int> {
  CounterState() : super(0);

  void increment() {
    value++;
  }
}

class ListState extends StateValue<List<String>> {
  ListState() : super(["Hey"]);

  void increment() {
    value = [...value, "Hey"];
  }
}
