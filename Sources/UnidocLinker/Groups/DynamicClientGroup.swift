import CodelinkResolution
import LexicalPaths
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

/// Abstracts over linker tables that are shared between package cultures
/// that depend on the same set of upstream package products.
struct DynamicClientGroup:Sendable
{
    /// An overlay of conformances declared by dependencies of modules in the
    /// current client group. The sets contain the protocol scalars only, with
    /// no constraints, because Swift does not allow conditional and
    /// unconditional conformances to coexist on the same type.
    private
    var conformances:Set<Unidoc.Vector>

    private(set)
    var codelinks:CodelinkResolver<Unidoc.Scalar>.Table
    private(set)
    var imports:[ModuleIdentifier]

    private
    let nodes:Set<Unidoc.Scalar>

    private
    init(conformances:Set<Unidoc.Vector>,
        codelinks:CodelinkResolver<Unidoc.Scalar>.Table,
        imports:[ModuleIdentifier],
        nodes:Set<Unidoc.Scalar>)
    {
        self.conformances = conformances
        self.codelinks = codelinks
        self.imports = imports
        self.nodes = nodes
    }
}
extension DynamicClientGroup
{
    init(nodes:Slice<SymbolGraph.Plane<UnidocPlane.Decl, Unidoc.Scalar?>>)
    {
        self.init(conformances: [],
            codelinks: .init(),
            imports: [],
            nodes: nodes.reduce(into: [])
            {
                if  let s:Unidoc.Scalar = $1
                {
                    $0.insert(s)
                }
            })
    }
}
extension DynamicClientGroup
{
    private mutating
    func remember(conforms t:Unidoc.Scalar, to p:Unidoc.Scalar)
    {
        self.conformances.update(with: .init(sub: t, dom: p))
    }
    func already(conforms t:Unidoc.Scalar, to p:Unidoc.Scalar) -> Bool
    {
        self.conformances.contains(.init(sub: t, dom: p))
    }
}
extension DynamicClientGroup
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

            guard let s:Unidoc.Scalar = snapshot.scalars[s]
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
            filter?.contains(`extension`.culture) ?? true
        {
            //  We only care about extensions to types that also have extensions in the
            //  package being linked.
            //
            //  This is a different condition than only caring about extensions to types
            //  that are *declared* in the package being linked.
            if  self.nodes.contains(outer.scalar)
            {
                for p:Int32 in `extension`.conformances
                {
                    if  let p:Unidoc.Scalar = snapshot.scalars[p]
                    {
                        //  If any extension (with any constraints) declares a conformance
                        //  to a protocol *p*, record it here.
                        self.remember(conforms: outer.scalar, to: p)
                    }
                }
            }

            if `extension`.features.isEmpty
            {
                continue
            }

            //  This can be completely different from the namespace of the extended type!
            let qualifier:ModuleIdentifier = snapshot.graph.namespaces[`extension`.namespace]
            for f:Int32 in `extension`.features
            {
                let symbol:Symbol.Decl.Vector = .init(snapshot.graph.decls[f],
                    self: outer.symbol)

                if  let f:Unidoc.Scalar = snapshot.scalars[f],
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
