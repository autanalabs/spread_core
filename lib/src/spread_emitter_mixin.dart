
import 'spread_state.dart';
import 'entity.dart';

/// A mixin named `StateEmitter` designed to facilitate state emission.
///
/// This mixin provides methods to emit states in various ways - by type, by a named identifier,
/// or based on an entity. It interacts with the `SpreadState` to dispatch these emitted states.
mixin StateEmitter {

  /// Emits a state of type `T`.
  ///
  /// This method is used to send a specific state type to the `SpreadState`.
  ///
  /// Type Parameter:
  ///   - `T`: The type of state being emitted.
  ///
  /// Parameters:
  ///   - `state`: The state of type `T` to be emitted.
  void emit<T>(T state) async {
    SpreadState().emit<T>(state);
  }

  /// Emits a state with a specific name.
  ///
  /// This method allows for the emission of states with a specified identifier/name.
  ///
  /// Parameters:
  ///   - `stateName`: The name or identifier for the state being emitted.
  ///   - `state`: The state data (of any type) to be emitted.
  void emitNamed(String stateName, dynamic state) async {
    SpreadState().emitNamed(stateName, state);
  }

  /// Emits a state based on an entity.
  ///
  /// This method is designed for cases where the state is associated with or based on
  /// a specific entity.
  ///
  /// Type Parameter:
  ///   - `T`: The type of entity which should extend from `Entity`.
  ///
  /// Parameters:
  ///   - `entity`: The entity of type `T` based on which the state is emitted.
  void emitEntity<T extends Entity>(T entity) async {
    SpreadState().emitEntity<T>(entity);
  }
}