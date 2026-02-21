import BSON

extension SymbolGraph {
    @frozen public enum ProductType: Hashable, Equatable, Sendable {
        case executable
        case library(LibraryType)
        case macro
        case plugin
        case snippet
        case test
    }
}
extension SymbolGraph.ProductType: CustomStringConvertible {
    @inlinable public var description: String {
        switch self {
        case .executable:           "executable"
        case .library(.automatic):  "library.automatic"
        case .library(.dynamic):    "library.dynamic"
        case .library(.static):     "library.static"
        case .macro:                "macro"
        case .plugin:               "plugin"
        case .snippet:              "snippet"
        case .test:                 "test"
        }
    }
}
extension SymbolGraph.ProductType: LosslessStringConvertible {
    @inlinable public init?(_ description: String) {
        switch description {
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
extension SymbolGraph.ProductType: BSONStringDecodable, BSONStringEncodable {
}
