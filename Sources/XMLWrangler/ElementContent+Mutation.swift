public extension Element.Content {
   public mutating func append(string: String) {
      guard case .string(let str) = self else { return }
      self = .string(str + string)
   }

   public mutating func append(object: Element) {
      guard case .objects(let objs) = self else { return }
      self = .objects(objs + [object])
   }

   public mutating func append(objects: Element...) {
      append(contentsOf: objects)
   }

   public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == Element {
      guard case .objects(let objs) = self else { return }
      self = .objects(objs + Array(objects))
   }
}

public extension RangeReplaceableCollection where Self: MutableCollection, Element == XMLWrangler.Element.Content {
   private var lastIndex: Index { return index(endIndex, offsetBy: -1) }

   public mutating func append(string: String) {
      guard !isEmpty && self[lastIndex].isString else { return append(.string(string)) }
      self[lastIndex].append(string: string)
   }

   public mutating func append(object: XMLWrangler.Element) {
      guard !isEmpty && self[lastIndex].isObjects else { return append([object]) }
      self[lastIndex].append(object: object)
   }

   public mutating func append(objects: XMLWrangler.Element...) {
      append(contentsOf: objects)
   }

   public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == XMLWrangler.Element {
      guard !isEmpty && self[lastIndex].isObjects else { return append(.objects(Array(objects))) }
      self[lastIndex].append(contentsOf: objects)
   }
}
