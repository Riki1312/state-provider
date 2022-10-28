import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:state_provider/state_provider.dart';

class TestState extends StateValue<int> {
  TestState(int value, {bool persistent = false})
      : super(value, persistent: persistent);

  bool accessed = false, closed = false;

  @override
  Future<void> onFirstAccess() async => accessed = true;

  @override
  Future<void> onClose() async => closed = true;
}

void main() {
  group('StateValue', () {
    test('create a simple StateValue', () {
      final state = StateValue<int>(0);

      expect(state.value, 0);
      state.value = 1;
      expect(state.value, 1);
    });

    test('get the stream of state values', () {
      final state = StateValue<int>(0);

      expect(state.stream, emitsInOrder([1, 2, 3]));
      state.value = 1;
      state.value = 2;
      state.value = 3;
    });

    test('close the stream', () {
      final state = StateValue<int>(0);

      state.close();
      expect(state.stream, emitsDone);
    });

    test('cannot emit new values if closed', () async {
      final state = StateValue<int>(0);

      await state.close();
      expect(() => state.value = 1, throwsStateError);
    });

    test('listeners are notified', () {
      final state = StateValue<int>(0);
      bool l1 = false, l2 = false;

      state.addListener(() => l1 = true);
      state.addListener(() => l2 = true);

      expect(l1, false);
      expect(l2, false);
      state.value = 1;

      expect(Future(() {
        expect(l1, true);
        expect(l2, true);
      }), completes);
    });

    test('removed listeners are not notified', () {
      final state = StateValue<int>(0);
      bool v1 = false, v2 = false;
      l1() => v1 = true;
      l2() => v2 = true;

      state.addListener(l1);
      state.addListener(l2);

      expect(v1, false);
      expect(v2, false);

      state.removeListener(l1);
      state.removeListener(l2);

      state.value = 1;
      expect(Future(() {
        expect(v1, false);
        expect(v2, false);
      }), completes);
    });

    test('onFirstAccess function is called', () {
      final state = TestState(0);

      expect(state.accessed, false);
      state.value = 1;
      expect(state.accessed, true);
    });

    test('onClose function is called', () async {
      final state = TestState(0);

      expect(state.closed, false);
      await state.close();
      expect(state.closed, true);
    });

    test('state is closed when all listeners are removed', () {
      final state = TestState(0);
      l1() {}
      l2() {}

      state.addListener(l1);
      state.addListener(l2);

      expect(state.closed, false);
      state.removeListener(l1);
      expect(state.closed, false);
      state.removeListener(l2);
      expect(state.closed, true);
    });

    test('state persistent is not closed when all listeners are removed', () {
      final state = TestState(0, persistent: true);
      l1() {}
      l2() {}

      state.addListener(l1);
      state.addListener(l2);

      expect(state.closed, false);
      state.removeListener(l1);
      state.removeListener(l2);
      expect(state.closed, false);
    });
  });

  group('StateProvider', () {
    testWidgets('create a StateProvider with a child Widget', (tester) async {
      final state = StateValue<int>(0);
      final provider = StateProvider(
        state: state,
        child: const Text('Child Text', textDirection: TextDirection.ltr),
      );

      await tester.pumpWidget(provider);
      expect(find.text('Child Text'), findsOneWidget);
    });

    testWidgets('retrieve the state value', (tester) async {
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          final v = StateProvider.of<StateValue<int>>(context).value;
          return Text('$v', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('listen to the state rebuild the widget', (tester) async {
      int buildCount = 0;
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          buildCount++;
          final s = StateProvider.of<StateValue<int>>(context);
          return Text('${s.value}', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(buildCount, 1);

      state.value = 20;

      await tester.pumpWidget(provider);
      expect(find.text('20'), findsOneWidget);
      expect(buildCount, 2);
    });

    testWidgets('reading the state does not rebuild the widget',
        (tester) async {
      int buildCount = 0;
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          buildCount++;
          final s = StateProvider.of<StateValue<int>>(context, listen: false);
          return Text('${s.value}', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(buildCount, 1);

      state.value = 20;

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      expect(buildCount, 1);
    });

    testWidgets('throws an error if the StateProvider is not found',
        (tester) async {
      final builder = Builder(builder: (context) {
        StateProvider.of<StateValue<String>>(context);
        return Container();
      });

      await tester.pumpWidget(builder);

      expect(
        tester.takeException(),
        isA<StateNotFoundException>()
            .having((err) => err.stateType, 'stateType', Type)
            .having((err) => err.widgetType, 'widgetType', Builder),
      );
    });
  });

  group('StateContext', () {
    testWidgets('read the state from a StateProvider', (tester) async {
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          final v = context.read<StateValue<int>>().value;
          return Text('$v', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('watch the state from a StateProvider', (tester) async {
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          final v = context.watch<StateValue<int>>().value;
          return Text('$v', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('reading the state does not rebuild the widget',
        (tester) async {
      int buildCount = 0;
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          buildCount++;
          final s = context.read<StateValue<int>>();
          return Text('${s.value}', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(buildCount, 1);

      state.value = 20;

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsNothing);
      expect(buildCount, 1);
    });

    testWidgets('watching the state rebuild the widget', (tester) async {
      int buildCount = 0;
      final state = StateValue<int>(10);
      final provider = StateProvider(
        state: state,
        child: Builder(builder: (context) {
          buildCount++;
          final s = context.watch<StateValue<int>>();
          return Text('${s.value}', textDirection: TextDirection.ltr);
        }),
      );

      await tester.pumpWidget(provider);
      expect(find.text('10'), findsOneWidget);
      expect(buildCount, 1);

      state.value = 20;

      await tester.pumpWidget(provider);
      expect(find.text('20'), findsOneWidget);
      expect(buildCount, 2);
    });

    testWidgets('throws an error if the StateProvider is not found',
        (tester) async {
      final builder = Builder(builder: (context) {
        context.read<StateValue<String>>();
        return Container();
      });

      await tester.pumpWidget(builder);

      expect(
        tester.takeException(),
        isA<StateNotFoundException>()
            .having((err) => err.stateType, 'stateType', Type)
            .having((err) => err.widgetType, 'widgetType', Builder),
      );
    });
  });
}
