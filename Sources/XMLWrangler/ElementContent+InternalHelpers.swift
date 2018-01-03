internal extension Element.Content {
   /// Returns `true` if `self` is `.string`, `false` otherwise.
   internal var isString: Bool {
      if case .string(_) = self { return true }
      return false
   }

   /// Returns `true` if `self` is `.object`, `false` otherwise.
   internal var isObject: Bool {
      if case .object(_) = self { return true }
      return false
   }

   /// Returns the associated `Element` if `self` is `.object`, `nil` otherwise.
   internal var object: Element? {
      switch self {
      case .string(_): return nil
      case .object(let obj): return obj
      }
   }

   /// Returns the associated `String` if `self` is `.string`, `nil` otherwise.
   internal var string: String? {
      switch self {
      case .string(let str): return str
      case .object(_): return nil
      }
   }
}
