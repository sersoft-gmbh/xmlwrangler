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

extension Element {
   @inlinable // Was inlinable before being deprecated
   @available(*, deprecated, message: "Use replace(elementAt:with:)", renamed: "replace(elementAt:with:)")
   public mutating func replace<Path: Collection>(elementAtPath path: Path, with newElement: Element) throws where Path.Element == Name {
      try replace(elementAt: path, with: newElement)
   }

   @inlinable // Was inlinable before being deprecated
   @available(*, deprecated, message: "Use replace(elementAt:with:)", renamed: "replace(elementAt:with:)")
   public mutating func replace(elementAtPath path: Name..., with newElement: Element) throws {
      try replace(elementAt: path, with: newElement)
   }
}
