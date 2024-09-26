
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
extension URI.Path
{
    /// Yields access to the last component of this path if it is not special,
    /// or an empty string. If the last component of this path does not exist,
    /// or is the special `..` component, this accessor will append the string
    /// to the path after the coroutine returns.
    ///
    /// Mutating this property will always leave a component containing the
    /// accessed string in the path, even if the coroutine left it in an empty
    /// state, similar to the way ``Dictionary.subscript(_:default:)`` behaves.
    ///
    /// >   Note:
    ///     Empty path components render as the special `.` component.
    @inlinable public
    var last:String
    {
        //  https://github.com/apple/swift/issues/71598
        get
        {
            if  case .push(let last)? = self.components.last
            {
                last
            }
            else
            {
                ""
            }
        }
        _modify
        {
            if  let index:Int = self.components.indices.last,
                case .push(var last) = self.components[index]
            {
                self.components[index] = .empty
                defer { self.components[index] = .push(last) }
                yield &last
            }
            else
            {
                var last:String = ""
                defer { self.components.append(.push(last)) }
                yield &last
            }
        }
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
    func append(_ component:consuming Component)
    {
        self.components.append(component)
    }
}
extension URI.Path
{
    @inlinable public static
    func / (self:consuming Self, component:consuming String) -> URI
    {
        .init(path: self.appending(.push(component)))
    }

    @inlinable public consuming
    func appending(_ component:consuming Component) -> Self
    {
        self.append(component)
        return self
    }

    @inlinable public mutating
    func append(_ component:consuming String)
    {
        self.append(.push(component))
    }

    @inlinable public mutating
    func append(_ component:some URI.Path.ComponentConvertible)
    {
        self.append(.push("\(component)"))
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

    /// Returns the lexically-normalized components of this path as percent-decoded
    /// strings. This function removes all special components from the path, therefore
    /// any “special-looking” strings in the output (such as `..`) were originally
    /// percent-encoded.
    @inlinable public
    func normalized(lowercase:Bool = false) -> [String]
    {
        var normalized:[String] = []
            normalized.reserveCapacity(self.count)

        for component:Component in self
        {
            switch component
            {
            case .empty:
                continue

            case .push(let component):
                normalized.append(lowercase ? component.lowercased() : component)

            case .pop:
                let _:String? = normalized.popLast()
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
