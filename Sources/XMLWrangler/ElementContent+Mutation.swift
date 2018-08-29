public extension RangeReplaceableCollection where Self: MutableCollection, Element == XMLWrangler.Element.Content {
   /// Appends either a new `.string` element, or if the last one is already `.string`, appends `string` to the last one.
   ///
   /// - Parameter string: The string to append.
   public mutating func append(string: String) {
      let lastIndex = index(endIndex, offsetBy: -1)
      if !isEmpty, case .string(let str) = self[lastIndex] {
         self[lastIndex] = .string(str + string)
      } else {
         append(.string(string))
      }
   }

   /// Appends an element wrapped as `.object`.
   ///
   /// - Parameter object: The element to append wrapped in `.object`.
   @inlinable
   public mutating func append(object: XMLWrangler.Element) {
      append(.object(object))
   }

   /// Appends the contents of a sequcence of elements wrapped as `.object`.
   ///
   /// - Parameter objects: The sequence of elements to append wrapped in `.object`.
   @inlinable
   public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == XMLWrangler.Element {
      append(contentsOf: objects.map { .object($0) })
   }

   /// Appends the one or more elements wrapped as `.object`.
   ///
   /// - Parameter objects: The elements to append wrapped in `.object`.
   @inlinable
   public mutating func append(objects: XMLWrangler.Element...) {
      append(contentsOf: objects)
   }

   /// Merges consecutive `.string` objects into one.
   public mutating func compress() {
      var currentIndex = startIndex
      while var nextIndex = index(currentIndex, offsetBy: 1, limitedBy: endIndex) {
         defer { currentIndex = nextIndex }
         guard case .string(let currentStr) = self[currentIndex] else { continue }
         var newStr = currentStr
         while nextIndex < endIndex, case .string(let nextStr) = self[nextIndex] {
            newStr += nextStr
            remove(at: nextIndex) // TODO: this might be a performance problem
         }
         self[currentIndex] = .string(newStr)
      }
   }

   /// Returns a compressed version of `self`, where all consecutive `.string` objects were merged into one.
   ///
   /// - Returns: A compressed version of `self`.
   /// - SeeAlso: `compress()`
   public func compressed() -> Self {
      var compressed = self
      compressed.compress()
      return compressed
   }
}


public extension Element {
   /// Appends a string to the content.
   ///
   /// - Parameter string: The string to append to the content.
   /// - SeeAlso: RangeReplacableCollection.append(string:)
   @inlinable
   public mutating func append(string: String) {
      content.append(string: string)
   }

   /// Appends an element to the content.
   ///
   /// - Parameter object: The element to append to the content.
   /// - SeeAlso: RangeReplacableCollection.append(object:)
   @inlinable
   public mutating func append(object: Element) {
      content.append(object: object)
   }

   /// Appends the contents of a sequence of elements to the content.
   ///
   /// - Parameter objects: The sequence of elements to append to the content.
   /// - SeeAlso: RangeReplacableCollection.append(contentsOf:)
   @inlinable
   public mutating func append<S: Sequence>(contentsOf objects: S) where S.Element == Element {
      content.append(contentsOf: objects)
   }

   /// Appends one or more objects to the content.
   ///
   /// - Parameter objects: The objects to append to the content.
   /// - SeeAlso: RangeReplacableCollection.append(objects:)
   @inlinable
   public mutating func append(objects: Element...) {
      append(contentsOf: objects)
   }
}
