
import 'spread_state.dart';

/// An abstract class named `SpreadObserver` designed for observing state changes of type `T`.
///
/// This class serves as a base for other classes aiming to observe specific state types.
/// Classes extending `SpreadObserver` should provide an implementation for the `onState` method,
/// which acts as a callback when the observed state type changes.
///
/// Generic Type:
///   - `T`: The type of state this observer is interested in.
abstract class SpreadObserver<T> {

  /// Registers the observer to listen to state changes of type `T`.
  ///
  /// This method subscribes the observer to the `SpreadState`, allowing it to receive updates
  /// whenever a state of type `T` is emitted.
  void selfRegister() async {
    SpreadState().subscribe<T>(onState);
  }

  /// Callback method that is invoked when a state of type `T` changes.
  ///
  /// Classes extending `SpreadObserver` should provide a concrete implementation of this method
  /// to handle the state changes as required.
  ///
  /// Parameters:
  ///   - `state`: The updated state of type `T`.
  void onState(T state);
}