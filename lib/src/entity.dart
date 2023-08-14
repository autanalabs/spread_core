
/// An abstract class representing a generic entity.
///
/// This class serves as a foundation for other entities requiring a unique identifier.
/// All subclasses must implement the `entityId` property, which acts as a unique ID.
abstract class Entity {
  String get entityId;
}
