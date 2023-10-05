import BSONDecoding
import BSONEncoding
import LexicalPaths
import ModuleGraphs
import Unidoc

extension Volume
{
    /// A stem is a special representation of a master record’s lexical name within a snapshot.
    /// A stem always begins with a ``ModuleIdentifier``.
    ///
    /// ## Empty stems
    ///
    /// By definition, a stem always contains at least one lexical component, even if its
    /// storage contains the empty string. In such a case, we define the first stem component
    /// to be an empty ``ModuleIdentifier``.
    ///
    /// ## Whitewashing
    ///
    /// The raw storage of a stem encodes a lexical path using a **whitewash transformation**.
    /// The whitewashed representation uses ASCII whitespace characters to encode path
    /// separators. This has three major advantages:
    ///
    /// 1.  Whitewashed strings are easy to split into components. Encoding declaration names
    ///     such as ``UnboundedRange_....(_:)`` without whitewashing requires decoders to have
    ///     knowledge of complex swift grammar rules.
    ///
    /// 1.  Whitespace characters are never legal within a declaration, module, article, or
    ///     file path component. This contrasts with characters such as `/`, which are legal
    ///     swift operator characters. This means that whitewashed stems never need any
    ///     escape sequences.
    ///
    /// 1.  Whitewashed strings are human-readable when they appear in debug output.
    ///
    /// ## Path orientation
    ///
    /// The specific separator characters used influence the URL representation of the stem.
    /// Specifically, the space character (`U+0020`) appears as a slash (`/`), and the
    /// horizontal tab character (`U+0009`) appears as a dot (`.`). This feature is called
    /// **path orientation**, and it decreases the likelihood of stem collisions under
    /// case-folding.
    ///
    /// ## Comparing stems
    ///
    /// Stems support relatively efficient comparisons, because they are stored as strings
    /// rather than arrays of substrings. The sort ordering is unicode-aware, and sorts the
    /// ``Unidoc.Decl.Orientation gay`` path orientation before the
    /// ``Unidoc.Decl.Orientation straight`` orientation.
    ///
    /// >   Note:
    ///     If you have a collection of stems that all share a common prefix, it may be even
    ///     more efficient to compare them by ``last`` component only.
    @frozen public
    struct Stem:RawRepresentable, Equatable, Hashable, Sendable
    {
        public
        var rawValue:String

        @inlinable public
        init(rawValue:String = "")
        {
            self.rawValue = rawValue
        }
    }
}
extension Volume.Stem:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.rawValue < rhs.rawValue
    }
}
extension Volume.Stem:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension Volume.Stem
{
    /// Returns the total number of components in this stem. This is ``depth`` plus one.
    ///
    /// Calling this property is faster than splitting the stem into components and accessing
    /// the array count.
    @inlinable public
    var components:Int { self.depth + 1 }

    /// Returns the number of *unqualified* path components in this stem. This is one fewer
    /// than the total number of components in this stem. The depth of a module stem is 0, and
    /// the depth of a top-level declaration stem is 1.
    @inlinable public
    var depth:Int
    {
        self.rawValue.reduce(into: 0)
        {
            if  $1.isWhitespace
            {
                $0 += 1
            }
        }
    }

    /// Returns the first lexical path component of this stem. If the stem is empty, this
    /// property returns an empty string.
    ///
    /// Calling this property is faster than splitting the stem into components and accessing
    /// the first array element.
    @inlinable public
    var first:Substring
    {
        if  let separator:String.Index = self.rawValue.firstIndex(where: \.isWhitespace)
        {
            return self.rawValue[..<separator]
        }
        else
        {
            return self.rawValue[...]
        }
    }
    /// Returns the last lexical path component of this stem. If the stem is empty, this
    /// property returns an empty string.
    ///
    /// Calling this property is faster than splitting the stem into components and accessing
    /// the last array element.
    @inlinable public
    var last:Substring
    {
        if  let separator:String.Index = self.rawValue.lastIndex(where: \.isWhitespace)
        {
            return self.rawValue[self.rawValue.index(after: separator)...]
        }
        else
        {
            return self.rawValue[...]
        }
    }
    /// Returns the unqualified name of this stem, if it contains more than one component,
    /// formatted with the dot character (`.`) as the path separator. If the stem contains
    /// only one component, this property returns that component unchanged.
    @inlinable public
    var name:Substring
    {
        if  let separator:String.Index = self.rawValue.firstIndex(where: \.isWhitespace)
        {
            return Self.format(self.rawValue[self.rawValue.index(after: separator)...])[...]
        }
        else
        {
            return self.rawValue[...]
        }
    }

    @inlinable public
    func split() -> (namespace:Substring, scope:[Substring], last:Substring)?
    {
        if  let i:String.Index = self.rawValue.firstIndex(where: \.isWhitespace),
            let j:String.Index = self.rawValue.lastIndex(where: \.isWhitespace)
        {
            let namespace:Substring = self.rawValue[..<i]
            let scope:[Substring]

            if  i < j
            {
                scope = self.rawValue[self.rawValue.index(after: i) ..< j].split(
                    whereSeparator: \.isWhitespace)
            }
            else
            {
                scope = []
            }

            let last:Substring = self.rawValue[self.rawValue.index(after: j)...]

            return (namespace, scope, last)
        }
        else
        {
            return nil
        }
    }
}
extension Volume.Stem:CustomStringConvertible
{
    @inlinable public
    var description:String { Self.format(self.rawValue) }
}
extension Volume.Stem
{
    @inlinable internal static
    func format(_ string:some StringProtocol, separator:UInt8 = 0x2E) -> String
    {
        .init(unsafeUninitializedCapacity: string.utf8.count)
        {
            var i:Int = $0.startIndex
            for codeunit:UInt8 in string.utf8
            {
                switch codeunit
                {
                case 0x09, 0x20:    $0[i] = 0x2E // '.'
                case let codeunit:  $0[i] = codeunit
                }

                i = $0.index(after: i)
            }
            return i
        }
    }
}
extension Volume.Stem
{
    @inlinable public mutating
    func append(straight component:some StringProtocol)
    {
        if !self.rawValue.isEmpty
        {
            self.rawValue.append(" ")
        }
        self.rawValue += component
    }
    @inlinable public mutating
    func append(gay component:some StringProtocol)
    {
        self.rawValue.append("\t")
        self.rawValue += component
    }
}
extension Volume.Stem
{
    @inlinable internal
    init(_ namespace:ModuleIdentifier)
    {
        self.init(rawValue: "\(namespace)")
    }
    @inlinable public
    init(_ namespace:ModuleIdentifier, _ name:Substring)
    {
        self.init(rawValue: "\(namespace) \(name)")
    }
    public
    init(
        _ namespace:ModuleIdentifier,
        _ path:UnqualifiedPath,
        orientation:Unidoc.Decl.Orientation)
    {
        self.init(rawValue: "\(namespace)")
        for component:String in path.prefix
        {
            self.append(straight: component)
        }
        switch orientation
        {
        case .straight: self.append(straight: path.last)
        case .gay:      self.append(gay: path.last)
        }
    }
}
extension Volume.Stem:BSONDecodable, BSONEncodable
{
}
