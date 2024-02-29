import Symbols

extension Unidoc
{
    @frozen public
    enum NounType:Equatable, Sendable
    {
        case stem(Citizenship, Phylum.DeclFlags?)
        /// Custom text, used to display article titles instead of their stems.
        case text(String)
    }
}
extension Unidoc.NounType
{
    @inlinable
    var decl:Phylum.DeclFlags?
    {
        switch self
        {
        case .stem(_, let decl):    decl
        case .text:                 nil
        }
    }

    @inlinable public
    var text:String?
    {
        switch self
        {
        case .stem:                 nil
        case .text(let text):       text
        }
    }
}
