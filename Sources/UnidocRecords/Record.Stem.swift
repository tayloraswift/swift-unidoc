import BSONDecoding
import BSONEncoding
import LexicalPaths
import ModuleGraphs
import Unidoc

extension Record
{
    @frozen public
    struct Stem:Equatable, Sendable
    {
        public
        let namespace:ModuleIdentifier
        public private(set)
        var infix:[String]
        public private(set)
        var last:Last?

        private
        init(_ namespace:ModuleIdentifier, _ last:Last? = nil)
        {
            self.namespace = namespace
            self.infix = []
            self.last = last
        }
        private
        init(_ namespace:ModuleIdentifier, _ infix:[String] = [], _ last:Last)
        {
            self.namespace = namespace
            self.infix = infix
            self.last = last
        }
    }
}
extension Record.Stem
{
    private static
    var separator:Unicode.Scalar { " " }

    public
    init(_ namespace:ModuleIdentifier, _ name:String)
    {
        self.init(namespace, .init(separator: Self.separator, component: name))
    }
    public
    init(
        _ namespace:ModuleIdentifier,
        _ path:UnqualifiedPath,
        orientation:Unidoc.Decl.Orientation)
    {
        switch orientation
        {
        case .gay:
            self.init(namespace, path.prefix, .init(separator: "\t", component: path.last))

        case .straight:
            self.init(namespace, path.prefix, .init(
                separator: Self.separator,
                component: path.last))
        }
    }
}
extension Record.Stem
{
    private mutating
    func append(_ last:Last)
    {
        self.last.map { self.infix.append($0.component) }
        self.last = last
    }
}
extension Record.Stem
{
    private
    init?(_ string:String.UnicodeScalarView)
    {
        var separator:String.Index?
        if  let index:String.Index = string.firstIndex(where: \.properties.isWhitespace)
        {
            self.init(.init(String.init(string[..<index])))
            separator = index
        }
        else
        {
            self.init(.init(string))
        }
        while let current:String.Index = separator
        {
            let start:String.Index = string.index(after: current)
            let remainder:Substring.UnicodeScalarView = string[start...]

            let component:String
            if  let next:String.Index = remainder.firstIndex(where: \.properties.isWhitespace)
            {
                separator = next
                component = .init(string[start ..< next])
            }
            else
            {
                separator = nil
                component = .init(remainder)
            }

            self.append(.init(separator: string[current], component: component))
        }
    }
}
extension Record.Stem:RawRepresentable
{
    public
    var rawValue:String
    {
        var stem:String = "\(self.namespace)"
        for infix:String in self.infix
        {
            stem += "\(Self.separator)\(infix)"
        }
        if  let last:Last = self.last
        {
            stem += "\(last.separator)\(last.component)"
        }
        return stem
    }

    public
    init?(rawValue:String)
    {
        self.init(rawValue.unicodeScalars)
    }
}
extension Record.Stem:BSONDecodable, BSONEncodable
{
}

extension Record.Stem:CustomStringConvertible
{
    public
    var description:String
    {
        var stem:String = "\(self.namespace)"
        for infix:String in self.infix
        {
            stem += ".\(infix)"
        }
        if  let last:Last = self.last
        {
            stem += ".\(last.component)"
        }
        return stem
    }
}
