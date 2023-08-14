
/// Represents an abstract use case in the application.
///
/// A use case signifies a single unit of business logic or domain logic. It embodies a specific
/// task or action the application can perform. Classes that extend `UseCase` are expected
/// to provide a concrete implementation for the `execute` method, indicating how the use case
/// operates when invoked.
abstract class UseCase {

  /// Executes the specific action or logic of the use case.
  ///
  /// Implementing classes should provide the actual logic that should be executed when this method
  /// is called, making the use case take effect.
  void execute();
}