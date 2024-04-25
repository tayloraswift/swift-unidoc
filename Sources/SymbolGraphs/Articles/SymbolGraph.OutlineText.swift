import BSON

extension SymbolGraph
{
    @frozen public
    struct OutlineText:Equatable, Hashable, Sendable
    {
        public
        let path:Substring
        public
        var fragment:Substring?

        @inlinable public
        init(path:Substring, fragment:Substring?)
        {
            self.path = path
            self.fragment = fragment
        }
    }
}
extension SymbolGraph.OutlineText
{
    @inlinable public
    var vector:[Substring]
    {
        self.path.split(separator: " ")
    }

    @inlinable public
    var words:Int
    {
        self.path.reduce(into: 1)
        {
            if  $1 == " "
            {
                $0 += 1
            }
        }
    }
}
extension SymbolGraph.OutlineText:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.fragment.map { "\(self.path)#\($0)" } ?? "\(self.path)"
    }
}
extension SymbolGraph.OutlineText:LosslessStringConvertible
{
    @inlinable public
    init(_ string:String)
    {
        if  let i:String.Index = string.lastIndex(of: "#")
        {
            self.init(path: string[..<i], fragment: string[string.index(after: i)...])
        }
        else
        {
            self.init(path: string[...], fragment: nil)
        }
    }
}
extension SymbolGraph.OutlineText
{
    @inlinable public
    init(vector:ArraySlice<String>, fragment:String?)
    {
        let path:String = vector.joined(separator: " ")
        self.init(path: path[...], fragment: fragment?[...])
    }
}
extension SymbolGraph.OutlineText:BSONStringDecodable, BSONStringEncodable
{
}
