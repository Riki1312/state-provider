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
      data: ValueNotifier<int>(1),
      //data: CounterState(),
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
            return Text('Count: ${context.watch<ValueNotifier<int>>().value}');
          },
        ),
        //Text('Count: ${StateProvider.of<ValueNotifier<int>>(context).value}'),
        //Text('Count: ${StateProvider.of<CounterState>(context).count}'),
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
          context.read<ValueNotifier<int>>().value++;
          //StateProvider.of<CounterState>(context, listen: false).increment();
        },
        child: const Text('Button'),
      ),
    );
  }
}

//

class CounterState extends ChangeNotifier {
  int _count = 0;

  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
