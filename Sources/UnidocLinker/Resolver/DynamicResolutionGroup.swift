import CodelinkResolution
import LexicalPaths
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

struct DynamicResolutionGroup:Sendable
{
    private(set)
    var optimizer:Optimizer

    private(set)
    var codelinks:CodelinkResolver<Unidoc.Scalar>.Table
    private(set)
    var imports:[ModuleIdentifier]

    init(
        optimizer:Optimizer = .init(),
        codelinks:CodelinkResolver<Unidoc.Scalar>.Table = .init(),
        imports:[ModuleIdentifier] = [])
    {
        self.optimizer = optimizer
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
            let symbol:Symbol.Decl = snapshot.graph.decls[s]

            guard let s:Unidoc.Scalar = snapshot.decls[s]
            else
            {
                continue
            }

            if  let citizen:SymbolGraph.Decl = node.decl
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
            if  let outer:SymbolGraph.Decl = node.decl ??
                    context[s.package]?.nodes[s]?.decl
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
            scalar:Unidoc.Scalar,
            symbol:Symbol.Decl,
            path:UnqualifiedPath
        ),
        snapshot:SnapshotObject,
        context:DynamicContext,
        filter:Set<Int>?)
    {
        for `extension`:SymbolGraph.Extension in extensions where
            // !`extension`.features.isEmpty &&
            filter?.contains(`extension`.culture) ?? true
        {
            let signature:Optimizer.ExtensionSignature = .init(
                conditions: `extension`.conditions.map  { $0.map { snapshot.decls[$0] } },
                extends: outer.scalar)

            self.optimizer.extensions[signature].update(with: `extension`, by: snapshot.decls)

            //  This can be completely different from the namespace of the extended type!
            let qualifier:ModuleIdentifier = snapshot.graph.namespaces[`extension`.namespace]
            for f:Int32 in `extension`.features
            {
                let symbol:Symbol.Decl.Vector = .init(snapshot.graph.decls[f],
                    self: outer.symbol)

                if  let f:Unidoc.Scalar = snapshot.decls[f],
                    let inner:SymbolGraph.Decl = context[f.package]?.nodes[f]?.decl
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
