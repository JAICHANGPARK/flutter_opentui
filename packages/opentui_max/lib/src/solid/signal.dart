typedef SignalListener<T> = void Function(T value);

final class SolidSignal<T> {
  SolidSignal(this._value);

  final Set<SignalListener<T>> _listeners = <SignalListener<T>>{};
  T _value;

  T get value => _value;

  set value(T next) {
    if (next == _value) {
      return;
    }
    _value = next;
    for (final listener in _listeners.toList(growable: false)) {
      listener(_value);
    }
  }

  void update(T Function(T current) updater) {
    value = updater(_value);
  }

  void listen(SignalListener<T> listener) {
    _listeners.add(listener);
  }

  void unlisten(SignalListener<T> listener) {
    _listeners.remove(listener);
  }
}

SolidSignal<T> createSignal<T>(T initialValue) => SolidSignal<T>(initialValue);
