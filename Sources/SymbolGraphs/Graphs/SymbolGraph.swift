import SemanticVersions
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
        try self.init(merging: try json.map(SymbolNamespace.init(json:)))
    }
    init(merging namespaces:[SymbolNamespace]) throws
    {
        let format:SemanticVersion

        if let first:SymbolNamespace = namespaces.first
        {
            format = first.metadata.version
        }
        else
        {
            throw SymbolGraphEmptyError.init()
        }

        for namespace:SymbolNamespace in namespaces
        {
            guard namespace.metadata.version == format
            else
            {
                throw SymbolGraphVersionError.inconsistent(Set<SemanticVersion>.init(
                    namespaces.lazy.map(\.metadata.version)).sorted())
            }
        }

        self.init(format: format)
    }
}
