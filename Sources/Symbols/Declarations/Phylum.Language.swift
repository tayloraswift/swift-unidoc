extension Phylum
{
    @frozen public
    enum Language:Int32, Equatable, Hashable, Sendable
    {
        case swift  = 0
        case c      = 1
        case cpp    = 2
    }
}
extension Phylum.Language:Comparable
{
    @inlinable public static
    func < (a:Self, b:Self) -> Bool { a.rawValue < b.rawValue }
}
extension Phylum.Language
{
    /// Returns the language union of the two operands.
    ///
    /// This is most useful when inferring the language of a module from the languages of its
    /// constituent source files. For example, a C++ module may contain `.c` or `.h` files.
    @inlinable public static
    func | (lhs:Self?, rhs:Self) -> Self
    {
        lhs.map { max($0, rhs) } ?? rhs
    }

    /// See ``|(_:_:)``.
    @inlinable public static
    func |= (lhs:inout Self?, rhs:Self)
    {
        lhs = lhs | rhs
    }
}
extension Phylum.Language:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .swift:    "swift"
        case .c:        "c"
        case .cpp:      "c++"
        }
    }
}
