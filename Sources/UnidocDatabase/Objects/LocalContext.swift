import SymbolGraphs

struct LocalContext
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[ScalarAddress: GlobalAddress]
    let projector:DynamicObject.Projector
    let docs:Documentation

    private
    init(hierarchy:[ScalarAddress: GlobalAddress],
        projector:DynamicObject.Projector,
        docs:Documentation)
    {
        self.hierarchy = hierarchy
        self.projector = projector
        self.docs = docs
    }
}
extension LocalContext
{
    init(projector:DynamicObject.Projector, docs:Documentation)
    {
        var hierarchy:[ScalarAddress: GlobalAddress] = [:]
            hierarchy.reserveCapacity(docs.graph.count)

        for scope:ScalarAddress in docs.graph.allocated
        {
            for `extension`:SymbolGraph.Extension in docs.graph[allocated: scope].extensions
            {
                for nested:ScalarAddress in `extension`.nested
                    where docs.graph.citizens.contains(nested)
                {
                    hierarchy[nested] = scope * projector
                }
            }
        }

        self.init(hierarchy: hierarchy, projector: projector, docs: docs)
    }
}
extension LocalContext
{
    subscript(address:GlobalAddress) -> SymbolGraph.Node?
    {
        //  Can use ``subscript(allocated:)`` because global addresses only
        //  reference citizen symbols.
        (address / self.projector).map { self.docs.graph[allocated: $0] }
    }

    func scope(of address:GlobalAddress) -> GlobalAddress?
    {
        if  let address:ScalarAddress = address / self.projector
        {
            return self.scope(of: address)
        }
        else
        {
            return nil
        }
    }
    func scope(of citizen:ScalarAddress) -> GlobalAddress?
    {
        self.hierarchy[citizen]
    }

    var translator:DynamicObject.Translator
    {
        self.projector.translator
    }
}
extension LocalContext:Identifiable
{
    var id:Int32
    {
        self.projector.translator.package
    }
}

extension LocalContext
{
    func project(extension:SymbolGraph.Extension, of scope:GlobalAddress) -> ExtensionProjection
    {
        .init(conditions: `extension`.conditions.map
            {
                $0.map { $0 * self.projector }
            },
            culture: self.translator[culture: `extension`.culture],
            scope: scope,
            conformances: `extension`.conformances.compactMap
            {
                $0 * self.projector
            },
            features: `extension`.features.compactMap
            {
                $0 * self.projector
            },
            nested: `extension`.nested.compactMap
            {
                $0 * self.projector
            })
    }
}
