public extension Element.Content {
   /// Searches for elements which match a given predicate. Optionally also recursive.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements. If it returns `true` the element will be included in the result.
   /// - Returns: The elements for which the `predicate` returned `true`. May be empty if the `predicate` never returned `true`.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: For `.empty` and `.string(_)`, this always returns an empty array.
   internal func find(recursive: Bool = false, elementsMatching predicate: (Element) throws -> Bool) rethrows -> [Element] {
      guard case .objects(let elems) = self else { return [] }
      let matches = try elems.filter(predicate)
      if recursive {
         return try matches + elems.flatMap { try $0.content.find(recursive: recursive, elementsMatching: predicate) }
      } else {
         return matches
      }
   }

   /// Finds the first occurence of an element that matches a given predicate.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements until it returns `true`.
   /// - Returns: The first element for which `predicate` returned `true`. `nil` if no element matched.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   internal func findFirst(recursive: Bool = false, elementMatching predicate: (Element) throws -> Bool) rethrows -> Element? {
      guard case .objects(let elems) = self else { return nil }
      let match = try elems.first(where: predicate)
      if recursive {
         return try match ?? elems.mapFirst { try $0.content.findFirst(recursive: recursive, elementMatching: predicate) }
      } else {
         return match
      }
   }

   /// Finds the last occurence of an element that matches a given predicate.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements starting at the end until it returns `true`.
   /// - Returns: The last element for which `predicate` returned `true`. `nil` if no element matched.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   internal func findLast(recursive: Bool = false, elementMatching predicate: (Element) throws -> Bool) rethrows -> Element? {
      guard case .objects(let elems) = self else { return nil }
      let reversed = elems.reversed()
      let match = try reversed.first(where: predicate)
      if recursive {
         return try match ?? reversed.mapFirst { try $0.content.findLast(recursive: recursive, elementMatching: predicate) }
      } else {
         return match
      }
   }

   /// Searches for elements with a given name. Optionally also recursive.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for elements.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The found elements in the order they were found in the tree. May be empty if nothing was found.
   /// - Note: For `.empty` and `.string(_)`, this always returns an empty array.
   public func find(elementsNamed name: String, recursive: Bool = false) -> [Element] {
      return find(recursive: recursive) { $0.name == name }
   }

   /// Finds the first occurence of an element with a given name.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for the first element.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The first element that's been found. `nil` if no element was found.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   public func findFirst(elementNamed name: String, recursive: Bool = false) -> Element? {
      return findFirst(recursive: recursive) { $0.name == name }
   }

   /// Finds the last occurence of an element with a given name.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for the last element.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The first element that's been found. `nil` if no element was found.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   public func findLast(elementNamed name: String, recursive: Bool = false) -> Element? {
      return findLast(recursive: recursive) { $0.name == name }
   }
}

public extension Sequence where Element == XMLWrangler.Element.Content {
   var allObjects: [XMLWrangler.Element] {
      return flatMap { $0.objects ?? [] }
   }

   var allStrings: [String] {
      return flatMap { $0.string }
   }
}

public extension Sequence where Element == XMLWrangler.Element.Content {
   /// Searches for elements which match a given predicate. Optionally also recursive.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements. If it returns `true` the element will be included in the result.
   /// - Returns: The elements for which the `predicate` returned `true`. May be empty if the `predicate` never returned `true`.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: For `.empty` and `.string(_)`, this always returns an empty array.
   internal func find(recursive: Bool = false, elementsMatching predicate: (XMLWrangler.Element) throws -> Bool) rethrows -> [XMLWrangler.Element] {
      let objects = allObjects
      let matches = try objects.filter(predicate)
      if recursive {
         return try matches + objects.flatMap { try $0.content.find(recursive: recursive, elementsMatching: predicate) }
      } else {
         return matches
      }
   }

   /// Finds the first occurence of an element that matches a given predicate.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements until it returns `true`.
   /// - Returns: The first element for which `predicate` returned `true`. `nil` if no element matched.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   internal func findFirst(recursive: Bool = false, elementMatching predicate: (XMLWrangler.Element) throws -> Bool) rethrows -> XMLWrangler.Element? {
      let objects = allObjects
      let match = try objects.first(where: predicate)
      if recursive {
         return try match ?? objects.mapFirst { try $0.content.findFirst(recursive: recursive, elementMatching: predicate) }
      } else {
         return match
      }
   }

   /// Finds the last occurence of an element that matches a given predicate.
   ///
   /// - Parameters:
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   ///   - predicate: The predicate to apply on elements starting at the end until it returns `true`.
   /// - Returns: The last element for which `predicate` returned `true`. `nil` if no element matched.
   /// - Throws: Any error that is thrown by the `predicate`.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   internal func findLast(recursive: Bool = false, elementMatching predicate: (XMLWrangler.Element) throws -> Bool) rethrows -> XMLWrangler.Element? {
      let objects = allObjects.reversed()
      let match = try objects.first(where: predicate)
      if recursive {
         return try match ?? objects.mapFirst { try $0.content.findLast(recursive: recursive, elementMatching: predicate) }
      } else {
         return match
      }
   }

   /// Searches for elements with a given name. Optionally also recursive.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for elements.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The found elements in the order they were found in the tree. May be empty if nothing was found.
   /// - Note: For `.empty` and `.string(_)`, this always returns an empty array.
   public func find(elementsNamed name: String, recursive: Bool = false) -> [XMLWrangler.Element] {
      return find(recursive: recursive) { $0.name == name }
   }

   /// Finds the first occurence of an element with a given name.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for the first element.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The first element that's been found. `nil` if no element was found.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   public func findFirst(elementNamed name: String, recursive: Bool = false) -> XMLWrangler.Element? {
      return findFirst(recursive: recursive) { $0.name == name }
   }

   /// Finds the last occurence of an element with a given name.
   ///
   /// - Parameters:
   ///   - name: The name with which to search for the last element.
   ///   - recursive: If `true` the search will recurse down the tree. `false` by default.
   /// - Returns: The first element that's been found. `nil` if no element was found.
   /// - Note: If `recursive` is `true`, recursion nevertheless happens lazily.
   ///         This means that one level is searched completely before recursing down into the next deeper level.
   /// - Note: For `.empty` and `.string(_)`, this always returns `nil`.
   public func findLast(elementNamed name: String, recursive: Bool = false) -> XMLWrangler.Element? {
      return findLast(recursive: recursive) { $0.name == name }
   }
}

fileprivate extension Sequence {
   /// Returns the result of a closure for the first element that the closure returns a non-nil result.
   ///
   /// - Parameter predicate: The predicate applied to the elements in self.
   /// - Returns: The result of `predicate` for the first element where `predicate` returned a non-nil result. Or nil if that never happens.
   /// - Throws: Any error thrown by `predicate`.
   fileprivate func mapFirst<T>(where predicate: (Element) throws -> T?) rethrows -> T? {
      for elem in self { if let result = try predicate(elem) { return result } }
      return nil
   }
}

