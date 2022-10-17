import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:state_provider/state_provider.dart';

class TestState extends StateValue<int> {
  TestState(int value) : super(value);

  bool firstAccess = false;

  @override
  void onFirstAccess() {
    firstAccess = true;
  }
}

void main() {
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

    testWidgets('retrieve the state value from a StateProvider',
        (tester) async {
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

    testWidgets('listen to the state rebuild the Widget', (tester) async {
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

    testWidgets('reading the state does not rebuild the Widget',
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

    testWidgets('the first access to the state triggers onFirstAccess',
        (tester) async {
      final provider = StateProvider(
        state: TestState(10),
        child: Builder(builder: (context) {
          final v = StateProvider.of<TestState>(context).value;
          return Text('$v', textDirection: TextDirection.ltr);
        }),
      );

      expect(provider.state.firstAccess, false);

      await tester.pumpWidget(provider);

      expect(find.text('10'), findsOneWidget);
      expect(provider.state.firstAccess, true);
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
}
