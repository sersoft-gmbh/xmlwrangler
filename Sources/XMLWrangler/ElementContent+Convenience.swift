public extension Element.Content {
   public func converted<T: LosslessStringConvertible>() -> T? {
      guard case .string(let str) = self else { return nil }
      return T(str)
   }
}
