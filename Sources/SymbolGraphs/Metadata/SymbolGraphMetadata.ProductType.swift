import BSONDecoding
import BSONEncoding

extension SymbolGraphMetadata
{
    @frozen public
    enum ProductType:Hashable, Equatable, Sendable
    {
        case executable
        case library(LibraryType)
        case macro
        case plugin
        case snippet
        case test
    }
}
extension SymbolGraphMetadata.ProductType:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .executable:           return "executable"
        case .library(.automatic):  return "library.automatic"
        case .library(.dynamic):    return "library.dynamic"
        case .library(.static):     return "library.static"
        case .macro:                return "macro"
        case .plugin:               return "plugin"
        case .snippet:              return "snippet"
        case .test:                 return "test"
        }
    }
}
extension SymbolGraphMetadata.ProductType:LosslessStringConvertible
{
    @inlinable public
    init?(_ description:String)
    {
        switch description
        {
        case "executable":          self = .executable
        case "library.automatic":   self = .library(.automatic)
        case "library.dynamic":     self = .library(.dynamic)
        case "library.static":      self = .library(.static)
        case "macro":               self = .macro
        case "plugin":              self = .plugin
        case "snippet":             self = .snippet
        case "test":                self = .test
        case _:                     return nil
        }
    }
}
extension SymbolGraphMetadata.ProductType:BSONStringDecodable, BSONStringEncodable
{
}
