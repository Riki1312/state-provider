import 'dart:math';

import 'package:flutter/material.dart';
import 'package:state_provider/state_provider.dart';

typedef CreateWidgetFunction<T> = Widget Function(T value);

abstract class DataValue {
  static defaultWidget<T>(T value) => const SizedBox.shrink();

  static Widget mapToWidget(
    DataValue value, {
    CreateWidgetFunction? loading,
    CreateWidgetFunction<String>? error,
    CreateWidgetFunction<String>? ready,
  }) {
    if (value is DataLoading) {
      return loading?.call(value) ?? defaultWidget(value);
    } else if (value is DataError) {
      return error?.call(value.message) ?? defaultWidget(value);
    } else if (value is DataReady) {
      return ready?.call(value.data) ?? defaultWidget(value);
    }

    return defaultWidget(value);
  }
}

class DataLoading extends DataValue {}

class DataError<T> extends DataValue {
  DataError(this.message);

  final T message;
}

class DataReady<T> extends DataValue {
  DataReady(this.data);

  final T data;
}

//

class UserState extends StateValue<DataValue> {
  UserState() : super(DataLoading(), onAccess: () => loadData());

  void loadData() async {
    print('Start loading data');

    value = DataLoading();

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
        //child: MyHomeText(),
        child: Text('Hello World'),
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
