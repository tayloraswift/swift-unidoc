import BSON

extension SymbolGraph
{
    @frozen public
    enum ModuleType:String, Hashable, Equatable, Sendable
    {
        case binary
        case executable
        case regular
        case macro
        case plugin

        //  We will never decode this from a manifest dump. But “extra” symbolgraphs
        //  are obviously snippets.
        case snippet

        case system
        case test
        case book
    }
}
extension SymbolGraph.ModuleType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        self.rawValue
    }
}
extension SymbolGraph.ModuleType:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        self.init(rawValue: description)
    }
}
extension SymbolGraph.ModuleType:BSONStringDecodable, BSONStringEncodable
{
}
