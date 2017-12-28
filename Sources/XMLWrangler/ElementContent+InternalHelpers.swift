internal extension Element.Content {
   internal var isString: Bool {
      if case .string(_) = self { return true }
      return false
   }

   internal var isObjects: Bool {
      if case .objects(_) = self { return true }
      return false
   }

   var objects: [Element]? {
      switch self {
      case .string(_): return nil
      case .objects(let objs): return objs
      }
   }

   var string: String? {
      switch self {
      case .string(let str): return str
      case .objects(_): return nil
      }
   }
}
