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
    @inlinable internal
    var swift:Bool
    {
        switch self
        {
        case .stem(_, let flags?):  flags.language == .swift
        case .stem(_, nil):         false
        case .text:                 false
        }
    }

    @inlinable public
    var text:String?
    {
        switch self
        {
        case .stem:             nil
        case .text(let text):   text
        }
    }
}
