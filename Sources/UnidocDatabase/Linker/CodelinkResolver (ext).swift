import CodelinkResolution
import LexicalPaths
import ModuleGraphs
import SymbolGraphs
import Symbols

extension CodelinkResolver<GlobalAddress>
{
    mutating
    func expose(upstream current:LocalContext, in context:GlobalContext)
    {
        for culture:SymbolGraph.Culture in current.graph.cultures
        {
            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                self.expose(namespace: namespace, from: current, in: context)
            }
        }
    }
    private mutating
    func expose(namespace:SymbolGraph.Namespace,
        from current:LocalContext,
        in global:GlobalContext)
    {
        let qualifier:ModuleIdentifier = current.graph.namespaces[namespace.index]
        for scalar:Int32 in namespace.range
        {
            guard let address:GlobalAddress = scalar * current.projector
            else
            {
                continue
            }

            let node:SymbolGraph.Node = current.graph.nodes[scalar]
            let symbol:ScalarSymbol = current.graph.symbols[scalar]

            if  let citizen:SymbolGraph.Scalar = node.scalar
            {
                self[qualifier, citizen.path].overload(with: .init(
                    target: .scalar(address),
                    phylum: citizen.phylum,
                    hash: .init(hashing: "\(symbol)")))
            }
            if  node.extensions.isEmpty
            {
                continue
            }
            //  Extension may extend a scalar from a different package.
            if  let outer:SymbolGraph.Scalar = node.scalar ??
                    global[address.package]?[scalar: address]?.scalar
            {
                self.expose(extensions: node.extensions,
                    extending: (address, outer, symbol),
                    from: current,
                    in: global)
            }
        }
    }
    private mutating
    func expose(extensions:[SymbolGraph.Extension],
        extending outer:
        (
            address:GlobalAddress,
            scalar:SymbolGraph.Scalar,
            symbol:ScalarSymbol
        ),
        from current:LocalContext,
        in global:GlobalContext)
    {
        for `extension`:SymbolGraph.Extension in extensions where
            !`extension`.features.isEmpty
        {
            //  This can be completely different from the namespace of the extended type!
            let qualifier:ModuleIdentifier = current.graph.namespaces[`extension`.namespace]
            for feature:Int32 in `extension`.features
            {
                let symbol:VectorSymbol = .init(current.graph.symbols[feature],
                    self: outer.symbol)

                if  let feature:GlobalAddress = feature * current.projector,
                    let inner:SymbolGraph.Scalar = global[scalar: feature]
                {
                    self[qualifier, outer.scalar.path, inner.path.last].overload(with: .init(
                        target: .vector(feature, self: outer.address),
                        phylum: inner.phylum,
                        hash: .init(hashing: "\(symbol)")))
                }
            }
        }
    }
}
