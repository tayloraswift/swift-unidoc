import SymbolGraphs

struct LocalContext
{
    /// Maps nested declarations to scopes. Scopes might be non-local.
    private
    let hierarchy:[Int32: GlobalAddress]
    let projector:DynamicObject.Projector
    let docs:Documentation

    private
    init(hierarchy:[Int32: GlobalAddress],
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
        var hierarchy:[Int32: GlobalAddress] = [:]
            hierarchy.reserveCapacity(docs.graph.nodes.count)

        for (scope, node):(Int32, SymbolGraph.Node) in zip(
            docs.graph.nodes.indices,
            docs.graph.nodes)
        {
            for `extension`:SymbolGraph.Extension in node.extensions
            {
                for nested:Int32 in `extension`.nested
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
        (address / self.projector).map { self.docs.graph.nodes[$0] }
    }

    func scope(of address:GlobalAddress) -> GlobalAddress?
    {
        (address / self.projector).map(self.scope(of:)) ?? nil
    }
    func scope(of citizen:Int32) -> GlobalAddress?
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
