import SemanticVersion
import JSONDecoding

public
struct SymbolGraph:Sendable
{
    public
    let format:SemanticVersion

    public
    init(format:SemanticVersion)
    {
        self.format = format
    }
}

extension SymbolGraph
{
    public
    init(merging json:[JSON.Object]) throws
    {
        try self.init(merging: try json.map(SymbolGraphNamespace.init(json:)))
    }
    init(merging namespaces:[SymbolGraphNamespace]) throws
    {
        let format:SemanticVersion

        if let first:SymbolGraphNamespace = namespaces.first
        {
            format = first.metadata.version.semantic
        }
        else
        {
            throw SymbolGraphEmptyError.init()
        }

        for namespace:SymbolGraphNamespace in namespaces
        {
            guard namespace.metadata.version.semantic == format
            else
            {
                throw SymbolGraphVersionError.inconsistent(Set<SemanticVersion>.init(
                    namespaces.lazy.map(\.metadata.version.semantic)).sorted())
            }
        }

        self.init(format: format)
    }
}
