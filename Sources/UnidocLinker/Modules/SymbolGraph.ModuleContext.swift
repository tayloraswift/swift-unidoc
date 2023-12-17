import CodelinkResolution
import LexicalPaths
import SymbolGraphs
import Symbols
import Unidoc

extension SymbolGraph
{
    /// Abstracts over linker tables that are shared between package cultures
    /// that depend on the same set of upstream package products.
    struct ModuleContext:Sendable
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
        var imports:[Symbol.Module]

        private
        let nodes:Set<Unidoc.Scalar>

        private
        init(conformances:Set<Unidoc.Vector>,
            codelinks:CodelinkResolver<Unidoc.Scalar>.Table,
            imports:[Symbol.Module],
            nodes:Set<Unidoc.Scalar>)
        {
            self.conformances = conformances
            self.codelinks = codelinks
            self.imports = imports
            self.nodes = nodes
        }
    }
}
extension SymbolGraph.ModuleContext
{
    init(nodes:Slice<SymbolGraph.Table<SymbolGraph.Plane.Decl, Unidoc.Scalar?>>)
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
extension SymbolGraph.ModuleContext
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
extension SymbolGraph.ModuleContext
{
    mutating
    func add(snapshot:Unidoc.Linker.Graph,
        context:borrowing Unidoc.Linker,
        filter:Set<Int>?)
    {
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            snapshot.cultures.indices,
            snapshot.cultures) where filter?.contains(c) ?? true
        {
            let module:Symbol.Module = snapshot.namespaces[c]

            self.imports.append(module)

            if  let c:Unidoc.Scalar = snapshot.scalars.namespaces[c]
            {
                self.codelinks[module].overload(with: .init(
                    target: .scalar(c),
                    phylum: nil,
                    hash: .init(hashing: "\(module)")))
            }

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
        snapshot:Unidoc.Linker.Graph,
        context:borrowing Unidoc.Linker,
        filter:Set<Int>?)
    {
        let qualifier:Symbol.Module = snapshot.namespaces[namespace.index]
        for s:Int32 in namespace.range
        {
            let node:SymbolGraph.DeclNode = snapshot.decls.nodes[s]
            let symbol:Symbol.Decl = snapshot.decls.symbols[s]

            guard let s:Unidoc.Scalar = snapshot.scalars.decls[s]
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
                    context[s.package]?.decls[s.citizen]?.decl
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
        snapshot:Unidoc.Linker.Graph,
        context:borrowing Unidoc.Linker,
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
                    if  let p:Unidoc.Scalar = snapshot.scalars.decls[p]
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
            let qualifier:Symbol.Module = snapshot.namespaces[`extension`.namespace]
            for f:Int32 in `extension`.features
            {
                let symbol:Symbol.Decl.Vector = .init(snapshot.decls.symbols[f],
                    self: outer.symbol)

                if  let f:Unidoc.Scalar = snapshot.scalars.decls[f],
                    let inner:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
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
