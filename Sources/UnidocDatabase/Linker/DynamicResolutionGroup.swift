import CodelinkResolution
import LexicalPaths
import ModuleGraphs
import SymbolGraphs
import Symbols

struct DynamicResolutionGroup:Sendable
{
    private(set)
    var codelinks:CodelinkResolver<Scalar96>.Table
    private(set)
    var imports:[ModuleIdentifier]

    init(codelinks:CodelinkResolver<Scalar96>.Table = .init(),
        imports:[ModuleIdentifier] = [])
    {
        self.codelinks = codelinks
        self.imports = imports
    }
}
extension DynamicResolutionGroup
{
    mutating
    func add(snapshot:SnapshotObject,
        context:DynamicContext,
        filter:Set<Int>?)
    {
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            snapshot.graph.cultures.indices,
            snapshot.graph.cultures) where
            filter?.contains(c) ?? true
        {
            self.imports.append(snapshot.graph.namespaces[c])
            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                self.add(namespace: namespace,
                    snapshot: snapshot,
                    context: context,
                    filter: filter)
            }
        }
    }
    private mutating
    func add(namespace:SymbolGraph.Namespace,
        snapshot:SnapshotObject,
        context:DynamicContext,
        filter:Set<Int>?)
    {
        let qualifier:ModuleIdentifier = snapshot.graph.namespaces[namespace.index]
        for s:Int32 in namespace.range
        {
            let node:SymbolGraph.Node = snapshot.graph.nodes[s]
            let symbol:ScalarSymbol = snapshot.graph.symbols[s]

            guard let s:Scalar96 = snapshot.declarations[s]
            else
            {
                continue
            }

            if  let citizen:SymbolGraph.Scalar = node.scalar
            {
                self.codelinks[qualifier, citizen.path].overload(with: .init(
                    target: .scalar(s),
                    phylum: citizen.phylum,
                    hash: .init(hashing: "\(symbol)")))
            }
            if  node.extensions.isEmpty
            {
                continue
            }
            //  Extension may extend a scalar from a different package.
            if  let outer:SymbolGraph.Scalar = node.scalar ??
                    context[s.package]?.nodes[s]?.scalar
            {
                self.add(extensions: node.extensions,
                    extending: (s, symbol, outer.path),
                    snapshot: snapshot,
                    context: context,
                    filter: filter)
            }
        }
    }
    private mutating
    func add(extensions:[SymbolGraph.Extension],
        extending outer:
        (
            scalar:Scalar96,
            symbol:ScalarSymbol,
            path:UnqualifiedPath
        ),
        snapshot:SnapshotObject,
        context:DynamicContext,
        filter:Set<Int>?)
    {
        for `extension`:SymbolGraph.Extension in extensions where
            !`extension`.features.isEmpty && filter?.contains(`extension`.culture) ?? true
        {
            //  This can be completely different from the namespace of the extended type!
            let qualifier:ModuleIdentifier = snapshot.graph.namespaces[`extension`.namespace]
            for f:Int32 in `extension`.features
            {
                let symbol:VectorSymbol = .init(snapshot.graph.symbols[f],
                    self: outer.symbol)

                if  let f:Scalar96 = snapshot.declarations[f],
                    let inner:SymbolGraph.Scalar = context[f.package]?.nodes[f]?.scalar
                {
                    self.codelinks[qualifier, outer.path, inner.path.last]
                        .overload(with: .init(
                            target: .vector(f, self: outer.scalar),
                            phylum: inner.phylum,
                            hash: .init(hashing: "\(symbol)")))
                }
            }
        }
    }
}
