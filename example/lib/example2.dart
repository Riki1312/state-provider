import 'dart:math';

import 'package:flutter/material.dart';
import 'package:state_provider/state_provider.dart';

import 'package:state_provider_example/data_value.dart';

class UserState extends StateValue<DataValue> {
  UserState() : super(DataLoading());

  @override
  void onFirstAccess() => loadData();

  void loadData() async {
    value = DataLoading();

    // Fake fetch data.
    await Future.delayed(const Duration(seconds: 2));
    int random = Random.secure().nextInt(10);

    if (random < 5) {
      value = DataError('Error fetching user data');
    } else {
      value = DataReady('User: Riccardo');
    }
  }
}

//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print("Build MyApp");

    return StateProvider(
      state: UserState(),
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
      body: const Center(
        child: MyHomeText(),
        //child: Text('Hello World'),
      ),
    );
  }
}

class MyHomeText extends StatelessWidget {
  const MyHomeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Build MyHomeText");

    return DataValue.mapToWidget(
      context.watch<UserState>().value,
      loading: (_) => const CircularProgressIndicator(),
      error: (message) => TextButton(
        onPressed: () => context.read<UserState>().loadData(),
        child: Text('$message - Retry'),
      ),
      ready: (data) => Text(data),
    );
  }
}
