import SymbolGraphs

extension Swiftinit
{
    struct ProductDemonym
    {
        let type:SymbolGraph.ProductType

        init(type:SymbolGraph.ProductType)
        {
            self.type = type
        }
    }
}
extension Swiftinit.ProductDemonym
{
    var title:String
    {
        switch self.type
        {
        case .executable:   "Executable Product"
        case .library:      "Library Product"
        case .macro:        "Macro Product"
        case .plugin:       "Plugin"
        case .snippet:      "Snippet"
        case .test:         "Test"
        }
    }

    var phrase:String
    {
        switch self.type
        {
        case .executable:   "an executable product"
        case .library:      "a library product"
        case .macro:        "a macro product"
        case .plugin:       "a plugin"
        case .snippet:      "a snippet"
        case .test:         "a test"
        }
    }
}
