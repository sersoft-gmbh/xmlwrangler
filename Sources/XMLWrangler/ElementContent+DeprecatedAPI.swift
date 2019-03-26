extension Element.Content {
   @available(*, deprecated, message: "Use conversion methods on Element")
   public func converted<T: LosslessStringConvertible>() -> T? {
      return string.flatMap(T.init)
   }

   @available(*, deprecated, message: "Use append on content or element")
   public mutating func append(string: String) {
      guard case .string(let str) = self else { return }
      self = .string(str + string)
   }
}
