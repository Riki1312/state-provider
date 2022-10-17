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
      //data: ValueNotifier<int>(1),
      data: CustomData(),
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
            return Text('Count: ${context.watch<CustomData>().value.toString()}');
            //return Text('Count: ${context.watch<ValueNotifier<int>>().value}');
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
          context.read<CustomData>().increment();
          //context.read<ValueNotifier<int>>().value++;
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

class CounterData extends StateData<int> {
  CounterData() : super(0);

  void increment() {
    emit(value + 1);
  }
}

class ListData extends StateData<List<String>> {
  ListData() : super(["Hey"]);

  void increment() {
    emit([...value, "Ciao"]);
  }
}

class CustomModel {
  CustomModel({required this.value1, required this.value2});

  String value1;
  String value2;

  @override
  String toString() {
    return 'CustomModel{value1: $value1, value2: $value2}';
  }
}

class CustomData extends StateData<CustomModel> {
  CustomData() : super(CustomModel(value1: "A", value2: "B"));

  void increment() {
    emit(CustomModel(value1: "NewA", value2: "NewB"));
  }
}
