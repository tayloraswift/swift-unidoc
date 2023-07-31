import BSONDecoding
import BSONEncoding
import LexicalPaths
import ModuleGraphs
import Unidoc
import URI

extension Record
{
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
extension Record.Stem:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(rawValue: stringLiteral)
    }
}
extension Record.Stem
{
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
}
extension Record.Stem
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
        precondition(!component.isEmpty)
        self.rawValue.append("\t")
        self.rawValue += component
    }
}
extension Record.Stem
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
        case .straight: self.append(gay: path.last)
        case .gay:      self.append(gay: path.last)
        }
    }
}
extension Record.Stem:BSONDecodable, BSONEncodable
{
}
