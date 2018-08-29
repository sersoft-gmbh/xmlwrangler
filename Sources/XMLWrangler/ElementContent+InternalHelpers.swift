internal extension Element.Content {
   /// Returns `true` if `self` is `.string`, `false` otherwise.
   @usableFromInline
   internal var isString: Bool {
      if case .string(_) = self { return true }
      return false
   }

   /// Returns `true` if `self` is `.object`, `false` otherwise.
   @usableFromInline
   internal var isObject: Bool {
      if case .object(_) = self { return true }
      return false
   }

   /// Returns the associated `Element` if `self` is `.object`, `nil` otherwise.
   @usableFromInline
   internal var object: Element? {
      switch self {
      case .string(_): return nil
      case .object(let obj): return obj
      }
   }

   /// Returns the associated `String` if `self` is `.string`, `nil` otherwise.
   @usableFromInline
   internal var string: String? {
      switch self {
      case .string(let str): return str
      case .object(_): return nil
      }
   }
}
