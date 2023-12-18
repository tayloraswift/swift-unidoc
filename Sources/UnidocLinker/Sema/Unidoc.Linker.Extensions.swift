import LexicalPaths
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics
import UnidocRecords

extension Unidoc.Linker
{
    struct Extensions
    {
        private
        var table:[ExtensionSignature: Extension]
        /// A copy of the current snapshot’s zone. This helps us avoid overlapping
        /// access when performing mutations on `self` while reading from the original
        /// snapshot context.
        private
        let zone:Unidoc.Edition

        init(table:[ExtensionSignature: Extension] = [:], zone:Unidoc.Edition)
        {
            self.table = table
            self.zone = zone
        }
    }
}
extension Unidoc.Linker.Extensions
{
    var count:Int
    {
        self.table.count
    }

    func sorted() -> [(key:Unidoc.Linker.ExtensionSignature, value:Unidoc.Linker.Extension)]
    {
        self.table.sorted { $0.value.id < $1.value.id }
    }
}
extension Unidoc.Linker.Extensions
{
    subscript(signature:Unidoc.Linker.ExtensionSignature) -> Unidoc.Linker.Extension
    {
        _read
        {
            let next:Unidoc.Group.ID = self.zone[extension: self.count]
            yield  self.table[signature, default: .init(id: next)]
        }
        _modify
        {
            let next:Unidoc.Group.ID = self.zone[extension: self.count]
            yield &self.table[signature, default: .init(id: next)]
        }
    }
}
extension Unidoc.Linker.Extensions
{
    /// Creates extension records from the given symbol graph extensions, performing any
    /// necessary de-duplication of protocol conformances and features.
    ///
    /// -   Returns:
    ///     A table containing *some* of the protocols that `scope` conforms to.
    ///
    /// This function only gathers protocol conformances declared by modules in the current
    /// package. The ultimate goal is to use these conformances to group valid features into
    /// extensions, and filter out duplicate or redundant features.
    ///
    /// For us to retain a feature, we require the conformance to the protocol that the feature
    /// is a member of to have been declared by at least one culture in the current package.
    ///
    /// For example, we could (retroactively) conform ``Optional`` to ``Sequence`` where
    /// ``Wrapped:Collection``, which would add all of ``Sequence``’s members to ``Optional`` as
    /// features.
    ///
    /// Because ``Optional`` does not “naturally” conform to ``Sequence``, we would retain all
    /// of those additional features, even though the current package did not declare them.
    ///
    /// Ideally, we would also want to retain features if the feature itself were declared in a
    /// culture of the current package. For example, we could extend ``Sequence`` with an
    /// additional member, and we would want that member to appear as a feature of every type
    /// that conforms to ``Sequence``, including those with conformances declared in other
    /// packages, such as ``Array``.
    ///
    /// At present though, SymbolGraphGen doesn’t emit vectors for these kinds of features, and
    /// we don’t want to broadcast them ourselves. So for now, those features are lost.
    mutating
    func add(_ extensions:[SymbolGraph.Extension],
        extending s:Int32,
        modules:[SymbolGraph.ModuleContext],
        context:inout Unidoc.Linker) -> ProtocolConformances<Int>
    {
        guard
        let s:Unidoc.Scalar = context.current.scalars.decls[s],
        let extendedSnapshot:Unidoc.Linker.Graph = context[s.package],
        let extendedDecl:SymbolGraph.Decl = extendedSnapshot.decls[s.citizen]?.decl
        else
        {
            let symbol:Symbol.Decl = context.current.decls.symbols[s]
            context.diagnostics[nil] = DroppedExtensionsError.extending(symbol,
                count: extensions.count)
            return [:]
        }

        let universal:Set<GenericConstraint<Unidoc.Scalar?>> =
            extendedDecl.signature.generics.constraints.reduce(into: [])
        {
            $0.insert($1.map { extendedSnapshot.scalars.decls[$0] })
        }
        /// Cache these signatures, since we need to perform two passes.
        let signatures:[Unidoc.Linker.ExtensionSignature] = extensions.map
        {
            .init(
                /// Remove constraints that are already present in the base declaration.
                conditions: $0.conditions.compactMap
                {
                    let constraint:GenericConstraint<Unidoc.Scalar?> = $0.map
                    {
                        context.current.scalars.decls[$0]
                    }
                    return universal.contains(constraint) ? nil : constraint
                },
                culture: $0.culture,
                extends: s)
        }

        let conformances:ProtocolConformances<Int> = .init(of: s,
            signatures: signatures,
            extensions: extensions,
            modules: modules,
            context: &context)

        for (p, conformances):(Unidoc.Scalar, [ProtocolConformance<Int>]) in conformances
        {
            for conformance:ProtocolConformance<Int> in conformances
            {
                let signature:Unidoc.Linker.ExtensionSignature = .init(
                    conditions: conformance.conditions,
                    culture: conformance.culture,
                    extends: s)

                self[signature].conformances.append(p)
            }
        }

        for (`extension`, signature):
            (SymbolGraph.Extension, Unidoc.Linker.ExtensionSignature) in zip(
            extensions,
            signatures)
        {
            //  It’s possible for two locally-disjoint extensions to coalesce
            //  into a single global extension due to constraint dropping...
            {
                /// Protocols usually come with many features, so as a premature
                /// optimization, we group the features by protocol.
                let features:[Unidoc.Scalar: [Unidoc.Scalar]] = `extension`.features.reduce(
                    into: [:])
                {
                    if  let p:Unidoc.Scalar = context.current.scope(of: $1),
                        let f:Unidoc.Scalar = context.current.scalars.decls[$1]
                    {
                        $0[p, default: []].append(f)
                    }
                }
                for (p, features):(Unidoc.Scalar, [Unidoc.Scalar]) in features
                {
                    //  This doesn’t have great complexity, but we expect that
                    //  multiple parallel conformances within the same package
                    //  to be quite rare.
                    if  conformances[to: p].contains(
                            where: { $0.culture == signature.culture })
                    {
                        $0.features += features
                    }
                }
                //  True nested declarations shouldn’t have duplicates, so we
                //  just store them without filtering.
                for d:Int32 in `extension`.nested
                {
                    if  let scalar:Unidoc.Scalar = context.current.scalars.decls[d]
                    {
                        $0.nested.append(scalar)
                    }
                }

                guard
                let article:SymbolGraph.Article = `extension`.article
                else
                {
                    return
                }
                guard case (nil, nil) = ($0.overview, $0.details)
                else
                {
                    context.diagnostics[nil] = DroppedPassagesError.fromExtension($0.id, of: s)
                    return
                }

                ($0.overview, $0.details) = context.resolving(
                    namespace: context.current.namespaces[`extension`.namespace],
                    module: modules[`extension`.culture],
                    scope: [String].init(extendedDecl.path))
                {
                    $0.link(article: article)
                }

            } (&self[signature])
        }

        return conformances
    }
}
extension Unidoc.Linker.Extensions
{
    func byNested() -> [Int32: Unidoc.Group.ID]
    {
        self.table.values.reduce(into: [:])
        {
            for nested:Unidoc.Scalar in $1.nested
            {
                $0[nested.citizen] = $1.id
            }
        }
    }
}