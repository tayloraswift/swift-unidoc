import LinkResolution
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
        /// This is needed to support URL translation from other package indexes.
        private(set)
        var caseless:CodelinkResolver<Unidoc.Scalar>.Table
        private(set)
        var imports:[Symbol.Module]

        private
        init()
        {
            self.conformances = []
            self.codelinks = .init()
            self.caseless = .init()
            self.imports = []
        }
    }
}
extension SymbolGraph.ModuleContext
{
    init(with build:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try build(&self)
        self.caseless = self.codelinks.caseless()
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

            if  let c:Unidoc.Scalar = snapshot.scalars.modules[c]
            {
                self.codelinks[module].overload(with: .init(
                    target: .scalar(c),
                    phylum: nil,
                    hash: .init(truncating: .module(module))))
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

            guard
            let s:Unidoc.Scalar = snapshot.scalars.decls[s]
            else
            {
                continue
            }

            if  let citizen:SymbolGraph.Decl = node.decl
            {
                //  Extensions extend a declaration in the same package. The namespace is just
                //  the namespace referenced in `namespace`.
                self.codelinks[qualifier, citizen.path].overload(with: .init(
                    target: .scalar(s),
                    phylum: citizen.phylum,
                    hash: .init(truncating: .decl(symbol))))

                self.add(extensions: node.extensions,
                    extending: (s, symbol, citizen),
                    qualifier: qualifier,
                    snapshot: snapshot,
                    context: context,
                    filter: filter)
            }
            else if
                let first:SymbolGraph.Extension = node.extensions.first,
                let outer:SymbolGraph.Decl = context[s.package]?.decls[s.citizen]?.decl
            {
                //  Extensions extend a declaration in a different package. We know all the
                //  extensions must share the same namespace, and we also know that a copy of
                //  that string is present in the symbol graph we are adding. Therefore, the
                //  namespace referenced by the first extension in the list is the namespace for
                //  all the extensions.
                let qualifier:Symbol.Module = snapshot.namespaces[first.namespace]

                //  We know that at least one such extension must exist, because otherwise the
                //  hollow node would not exist in the symbol graph in the first place. If there
                //  are no extensions, the node should not be hollow, and we should have taken
                //  the other branch of the `if` statement.
                self.add(extensions: node.extensions,
                    extending: (s, symbol, outer),
                    qualifier: qualifier,
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
            decl:SymbolGraph.Decl
        ),
        qualifier:Symbol.Module,
        snapshot:Unidoc.Linker.Graph,
        context:borrowing Unidoc.Linker,
        filter:Set<Int>?)
    {
        //  We really shouldn’t have to do this, but lib/SymbolGraphGen just sucks.
        for f:Int32 in outer.decl.features
        {
            var symbol:Symbol.Decl.Vector
            {
                .init(snapshot.decls.symbols[f], self: outer.symbol)
            }
            if  let f:Unidoc.Scalar = snapshot.scalars.decls[f],
                let inner:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
            {
                self.codelinks[qualifier, outer.decl.path, inner.path.last]
                    .overload(with: .init(
                        target: .vector(f, self: outer.scalar),
                        phylum: inner.phylum,
                        hash: .init(truncating: .decl(symbol))))
            }
        }

        for `extension`:SymbolGraph.Extension in extensions where
            filter?.contains(`extension`.culture) ?? true
        {
            //  We only care about extensions to types that also have extensions in the
            //  package being linked.
            //
            //  This is a different condition than only caring about extensions to types
            //  that are *declared* in the package being linked.
            if  context.nodes.contains(outer.scalar)
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

            for f:Int32 in `extension`.features
            {
                var symbol:Symbol.Decl.Vector
                {
                    .init(snapshot.decls.symbols[f], self: outer.symbol)
                }
                if  let f:Unidoc.Scalar = snapshot.scalars.decls[f],
                    let inner:SymbolGraph.Decl = context[f.package]?.decls[f.citizen]?.decl
                {
                    self.codelinks[qualifier, outer.decl.path, inner.path.last]
                        .overload(with: .init(
                            target: .vector(f, self: outer.scalar),
                            phylum: inner.phylum,
                            hash: .init(truncating: .decl(symbol))))
                }
            }
        }
    }
}
