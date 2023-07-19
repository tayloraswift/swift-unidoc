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
    fileprivate static
    func += (self:inout Self, characters:some StringProtocol)
    {
        self.rawValue += characters
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
    init(_ namespace:ModuleIdentifier, _ name:String)
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
            self += " \(component)"
        }
        switch orientation
        {
        case .straight: self +=  " \(path.last)"
        case .gay:      self += "\t\(path.last)"
        }
    }
}
extension Record.Stem
{
    public
    init(uri:(first:Substring, rest:ArraySlice<String>))
    {
        self.init()
        self.append(compound: uri.first)
        for compound:String in uri.rest
        {
            self += " "
            self.append(compound: compound)
        }
    }
    private mutating
    func append(compound:some StringProtocol)
    {
        if  let dot:String.Index = compound.firstIndex(of: ".")
        {
            self += "\(compound[..<dot])\t\(compound[compound.index(after: dot)...])"
        }
        else
        {
            self += compound
        }
    }
}
extension Record.Stem
{
    public static
    func += (uri:inout URI.Path, self:Self)
    {
        func transform(_ compound:Substring) -> String
        {
            var transformed:String = ""
                transformed.reserveCapacity(compound.utf8.count)
            for character:Character in compound
            {
                switch character
                {
                case "\t":  transformed += "."
                case   _ :  transformed += character.lowercased()
                }
            }
            return transformed
        }

        var first:Bool = true
        for compound:Substring in self.rawValue.split(separator: " ")
        {
            if first
            {
                uri.last += transform(compound)
                first = false
            }
            else
            {
                uri.append(transform(compound))
            }
        }
    }
}
extension Record.Stem:BSONDecodable, BSONEncodable
{
}
