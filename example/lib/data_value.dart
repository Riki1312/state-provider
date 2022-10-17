import 'package:flutter/widgets.dart';

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
