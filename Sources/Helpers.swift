
#if !swift(>=4.0)
   public extension ExpressibleByStringLiteral where StringLiteralType: ExpressibleByExtendedGraphemeClusterLiteral,
   StringLiteralType.ExtendedGraphemeClusterLiteralType == ExtendedGraphemeClusterLiteralType {
      public init(extendedGraphemeClusterLiteral value: Self.ExtendedGraphemeClusterLiteralType) {
         self.init(stringLiteral: Self.StringLiteralType(extendedGraphemeClusterLiteral: value))
      }
   }

   public extension ExpressibleByExtendedGraphemeClusterLiteral where ExtendedGraphemeClusterLiteralType: ExpressibleByUnicodeScalarLiteral,
   ExtendedGraphemeClusterLiteralType.UnicodeScalarLiteralType == UnicodeScalarLiteralType {
      public init(unicodeScalarLiteral value: Self.UnicodeScalarLiteralType) {
         self.init(extendedGraphemeClusterLiteral: Self.ExtendedGraphemeClusterLiteralType(unicodeScalarLiteral: value))
      }
   }
#endif
