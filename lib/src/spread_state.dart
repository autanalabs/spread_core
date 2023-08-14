import 'dart:async';
import 'package:spread_core/src/entity.dart';

/// Manages state storage and notifications in the Spread framework.
///
/// `SpreadState` offers a singleton pattern, ensuring a single point of state storage and
/// management. States can be stored based on type, name, or associated entities.
/// It also offers subscription mechanisms to listen to state changes.
class SpreadState {
  static final SpreadState _singleton = SpreadState._internal();
  late final Map<String, dynamic> _root;
  late final Map<String, List<StreamController<dynamic>>> _listeners;

  factory SpreadState() {
    return _singleton;
  }

  SpreadState._internal() {
    _root = {};
    _listeners = {};
  }

  /// Retrieves a state based on its type.
  T? get<T>() {
    final stateName = 'type:${T.toString()}';
    return getNamed<T>(stateName);
  }

  /// Retrieves a state based on its name.
  T? getNamed<T>(String stateName) {
    return _root[stateName] as T?;
  }

  /// Retrieves a state based on an entity's ID and parameterized Type
  T? getEntity<T>(String entityId) {
    final stateName = 'entity:${T.toString()}#$entityId';
    return getNamed<T>(stateName);
  }

  /// Emits a new state update based on type.
  void emit<T>(T state) async {
    final stateName = 'type:${T.toString()}';
    emitNamed(stateName, state);
  }

  /// Emits a new state update based on a name.
  void emitNamed(String stateName, dynamic state) async {
    if (!_root.containsKey(stateName)) {
      _root.putIfAbsent(stateName, () => state);
    } else {
      _root[stateName] = state;
    }
    _emit(stateName, state);
  }

  /// Emits a new state update based on an entity.
  void emitEntity<T extends Entity>(T entity) async {
    final stateName = 'entity:${T.toString()}#${entity.entityId}';
    emitNamed(stateName, entity);
  }

  void _emit(String stateName, dynamic state) async {
    final list = _listeners[stateName];
    if (list != null) {
      for (var controller in list) {
        _sendState(controller, state);
      }
    }
  }

  void _sendState(StreamController<dynamic> controller, dynamic state) async {
    controller.add(state);
  }

  /// Subscribes to state changes of a specific type.
  Future<Subscription> subscribe<T>(void Function(T) onChange) async {
    final stateName = 'type:${T.toString()}';
    final list = _listeners[stateName] ?? [];
    final controller = StreamController<T>();
    controller.stream.listen(onChange);
    list.add(controller);
    _listeners.putIfAbsent(stateName, () => list);
    return Subscription._internal(stateName, controller);
  }

  /// Subscribes to state changes of a specific name.
  Future<Subscription> subscribeNamed(
      String stateName, void Function(dynamic) onChange) async {
    final list = _listeners[stateName] ?? [];
    final controller = StreamController<dynamic>();
    controller.stream.listen(onChange);
    list.add(controller);
    _listeners.putIfAbsent(stateName, () => list);
    return Subscription._internal(stateName, controller);
  }

  /// Subscribes to state changes based on an entity.
  Future<Subscription> subscribeEntity<T extends Entity>(
      T entity, void Function(T) onChange) async {
    final stateName =
        'entity:${entity.runtimeType.toString()}#${entity.entityId}';
    final list = _listeners[stateName] ?? [];
    final controller = StreamController<T>();
    controller.stream.listen(onChange);
    list.add(controller);
    _listeners.putIfAbsent(stateName, () => list);
    return Subscription._internal(stateName, controller);
  }

  void _unSubscribe(Subscription subscription) async {
    final list = _listeners[subscription._stateName];
    if (list != null) {
      list.remove(subscription._controller);
      if (list.isEmpty) {
        _listeners.remove(subscription._stateName);
      }
    }
    subscription._controller.close();
  }
}

/// Represents a subscription to state changes within the Spread framework.
///
/// A `Subscription` allows for the unsubscription of state change notifications when they're
/// no longer needed.
class Subscription {
  final String _stateName;
  final StreamController<dynamic> _controller;

  Subscription._internal(String stateName, StreamController<dynamic> controller)
      : _controller = controller,
        _stateName = stateName;

  /// Unsubscribes from state change notifications.
  void unSubscribe() async {
    SpreadState()._unSubscribe(this);
  }
}
