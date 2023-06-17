
extension URI
{
    @frozen public
    struct Path:Equatable, Hashable, Sendable
    {
        @usableFromInline internal
        var components:[Component]

        @inlinable public
        init(components:[Component])
        {
            self.components = components
        }
    }
}
extension URI.Path:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Component...)
    {
        self.init(components: arrayLiteral)
    }
}
extension URI.Path:Sequence
{
    @inlinable public
    func withContiguousStorageIfAvailable<T>(
        _ body:(UnsafeBufferPointer<Component>) throws -> T) rethrows -> T?
    {
        try self.components.withContiguousStorageIfAvailable(body)
    }
}
extension URI.Path:MutableCollection
{
    @inlinable public mutating
    func withContiguousMutableStorageIfAvailable<T>(
        _ body:(inout UnsafeMutableBufferPointer<Component>) throws -> T) rethrows -> T?
    {
        try self.components.withContiguousMutableStorageIfAvailable(body)
    }
}
extension URI.Path:RandomAccessCollection
{
    @inlinable public
    var startIndex:Int
    {
        self.components.startIndex
    }
    @inlinable public
    var endIndex:Int
    {
        self.components.endIndex
    }
    @inlinable public
    subscript(index:Int) -> Component
    {
        _read
        {
            yield  self.components[index]
        }
        _modify
        {
            yield &self.components[index]
        }
    }
}
extension URI.Path:RangeReplaceableCollection
{
    @inlinable public
    init()
    {
        self.init(components: [])
    }

    @inlinable public mutating
    func reserveCapacity(_ capacity:Int)
    {
        self.components.reserveCapacity(capacity)
    }
    @inlinable public mutating
    func replaceSubrange(_ range:Range<Int>, with elements:some Collection<Component>)
    {
        self.components.replaceSubrange(range, with: elements)
    }
    @inlinable public mutating
    func append(_ component:Component)
    {
        self.components.append(component)
    }
}
extension URI.Path
{
    @inlinable public mutating
    func append(_ component:String)
    {
        self.append(.push(component))
    }

    @inlinable public mutating
    func normalize()
    {
        self = self.normalized()
    }

    @inlinable public
    func normalized() -> Self
    {
        var normalized:Self = []
            normalized.reserveCapacity(self.count)

        for component:Component in self
        {
            switch component
            {
            case .empty:
                continue

            case .push(let component):
                normalized.append(component)

            case .pop:
                let _:URI.Path.Component? = normalized.popLast()
            }
        }
        return normalized
    }
}
extension URI.Path:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        "/\(self.components.lazy.map(\.description).joined(separator: "/"))"
    }
}
extension URI.Path:LosslessStringConvertible
{
    /// Parses an absolute path from a string. This function does not lexically
    /// normalize the path components.
    ///
    /// Parsing a root expression (`/`) with this parser produces a path with no
    /// components. Otherwise, trailing slashes will generate empty components.
    /// Note that unless it is a root expression, parsing a string that consists
    /// of *n* repeating slashs will generate a path with *n* empty path components.
    @inlinable public
    init?(_ description:String)
    {
        self.init(description[...])
    }
}
extension URI.Path
{
    public
    init?(_ string:Substring)
    {
        do
        {
            self = try URI.AbsolutePathRule<String.Index>.parse(string.utf8)
        }
        catch
        {
            return nil
        }
    }

    /// Parses a relative path from a string. This function does not lexically
    /// normalize the path components.
    ///
    /// This function can accept an empty string, and will produce a path with
    /// no components. Parsing a root expression (`/`) with this parser produces
    /// a path with a two empty components.
    ///
    /// >   Warning:
    ///     This parser will not round-trip with ``description``; this type
    ///     always formats itself with a leading slash.
    public
    init?(relative:Substring)
    {
        if  relative.isEmpty
        {
            self = []
            return
        }
        do
        {
            self = try URI.RelativePathRule<String.Index>.parse(relative.utf8)
        }
        catch
        {
            return nil
        }
    }
}
