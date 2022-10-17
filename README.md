# State Provider

A super simple state management library for [Flutter](https://flutter.dev/).

The whole implementation is less than 200 lines of code, including docs comments.
It uses no external libraries and is therefore really easy to integrate and debug.

Super simple doesn't mean poorly implemented, though. It's actually pretty powerful:

- 🪨 Built around **immutable states**, making it easier to keep track of state changes in the application.
- 🌌 Full **support for streams**, allows states to interact with each other (and other cool stuff).
- 🕹️ Efficient separation of states data from states mutation logic.
- ✨ Convenient access to states directly from the widget context (optimize rebuilds).

Inspired by popular libraries like [Provider](https://pub.dev/packages/provider)
and [Bloc](https://pub.dev/packages/bloc), but built around Flutter's existing
tools like `Listenable`, `StreamController`, and `InheritedNotifier`.

And it's fully covered by tests 💯.

## Getting Started

### Installation

Add this to your `pubspec.yaml` file:

```yaml
dependencies:
  state_provider:
    git:
      url: https://github.com/Riki1312/state-provider.git
```

Then run `flutter pub get`.

### Counter example

Create a class that contains the counter state and extends `StateValue`.

```dart
class CounterState extends StateValue<int> {
  CounterState() : super(0);

  void increment() {
    value++;
  }
}
```

Use the `StateProvider` widget to inject the state into the tree.

```dart
StateProvider(
  state: CounterState(),
  child: ...,
);
```

Retrieve the state from a descendant widget of the `StateProvider`.

(This uses the type of the state, in this case `CounterState`).

```dart
Builder(
  builder: (context) => Text('${context.watch<CounterState>().value}'),
),

ElevatedButton(
  onPressed: () {
    context.read<CounterState>().increment();
  },
  child: ...,
),
```

The difference between `context.watch` and `context.read` is that `watch` rebuilds
the widget whenever the state value changes, while `read` only returns the state.

### Counter example with streams

Thanks to the streams we can extend the previous example by adding a second state
that works with the first to keep track of odd numbers inside a list.

```dart
class ListState extends StateValue<List<String>> {
  ListState(this.counterState) : super([]) {
    counterState.stream.where((number) => number.isOdd).listen((number) {
      value = [...value, "Odd: $number"];
    });
  }

  final CounterState counterState;
}
```

Let's add another `StateProvider` for the new state.

```dart
StateProvider(
  state: ListState(context.read<CounterState>()),
  child: ...,
),
```

Now we can use the new state in the widget tree.

```dart
Builder(
  builder: (context) => Text('${context.watch<ListState>().value}'),
),
```

### Counter example alternative

Instead of creating a new class for very simple cases, you can use `StateValue` directly.

```dart
StateProvider(
  state: StateValue<int>(0),
  child: ...,
),
```

```dart
Builder(
  builder: (context) => Text('${context.watch<StateValue<int>>().value}'),
),

ElevatedButton(
  onPressed: () {
    context.read<StateValue<int>>().value++;
  },
  child: ...,
),
```

## Contributing and Feedback

If you have any questions or suggestions, feel free to open an issue or a pull request.

## License

Licensed under the [MIT License](/LICENSE).
