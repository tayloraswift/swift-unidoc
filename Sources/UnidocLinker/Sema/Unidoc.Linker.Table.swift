import LexicalPaths
import Signatures
import SourceDiagnostics
import SymbolGraphs
import Symbols
import Unidoc
import UnidocRecords

extension Unidoc.Linker
{
    struct Table<Group> where Group:Unidoc.LinkerIndexable
    {
        private
        var table:[Group.Signature: Group]

        private
        init(table:[Group.Signature: Group])
        {
            self.table = table
        }
    }
}
extension Unidoc.Linker.Table:ExpressibleByDictionaryLiteral
{
    init(dictionaryLiteral:(Group.Signature, Never)...)
    {
        self.init(table: [:])
    }
}
extension Unidoc.Linker.Table
{
    consuming
    func load() -> [(key:Group.Signature, value:Group)]
    {
        var extensions:[(key:Group.Signature, value:Group)]

        extensions = self.table.filter { !$0.value.isEmpty }
        extensions.sort { $0.1.id < $1.1.id }

        return extensions
    }
}
extension Unidoc.Linker.Table
{
    private
    var next:Unidoc.LinkerIndex<Group> { .init(ordinal: self.table.count) }

    subscript(signature:Group.Signature) -> Group
    {
        _read
        {
            let id:Unidoc.LinkerIndex<Group> = self.next
            yield  self.table[signature, default: .init(id: id)]
        }
        _modify
        {
            let id:Unidoc.LinkerIndex<Group> = self.next
            yield &self.table[signature, default: .init(id: id)]
        }
    }
}

extension Unidoc.Linker.Table<Unidoc.Conformers>
{
    mutating
    func add(conformances:Unidoc.ConformanceList, of type:Unidoc.Scalar)
    {
        /// Although the order in which we visit the protocols is non-deterministic,
        /// the order of the accumulated conformances is still deterministic since each
        /// protocol only has one conditions array.
        for (p, conditions):(Unidoc.Scalar, [Unidoc.ExtensionConditions]) in conformances
        {
            for condition:Unidoc.ExtensionConditions in conditions
            {
                self[.conforms(to: p, in: condition.culture)].append(conformer: type,
                    where: condition.constraints)
            }
        }
    }
}

extension Unidoc.Linker.Table<Unidoc.Extension>
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
        context:inout Unidoc.Linker) -> Unidoc.ConformanceList
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

        let universal:Set<GenericConstraint<Unidoc.Scalar>> =
            extendedDecl.signature.generics.constraints.reduce(into: [])
        {
            $0.insert($1.map { extendedSnapshot.scalars.decls[$0] })
        }
        /// Cache these constraints, since we need to perform two passes.
        let conditions:[Unidoc.ExtensionConditions] = extensions.map
        {
            /// Remove constraints that are already present in the base declaration.
            .init(
                constraints: $0.conditions.compactMap
                {
                    let constraint:GenericConstraint<Unidoc.Scalar> = $0.map
                    {
                        context.current.scalars.decls[$0]
                    }
                    return universal.contains(constraint) ? nil : constraint
                },
                culture: $0.culture)
        }

        let conformances:Unidoc.ConformanceList = .init(of: s,
            conditions: conditions,
            extensions: extensions,
            modules: modules,
            context: &context)

        for (p, conformances):(Unidoc.Scalar, [Unidoc.ExtensionConditions])
            in conformances
        {
            for conformance:Unidoc.ExtensionConditions in conformances
            {
                self[.extends(s, where: conformance)].conformances.append(p)
            }
        }

        for (var conditions, `extension`):
            (Unidoc.ExtensionConditions, SymbolGraph.Extension) in zip(
            conditions,
            extensions)
        {
            if  case .protocol = extendedDecl.phylum
            {
                /// Lint tautological `Self:#Self` constraints. These exist in extensions to
                /// ``RawRepresentable`` in the standard library.
                conditions.constraints.removeAll
                {
                    if  case .where("Self", is: .conformer, to: let type) = $0,
                        case s? = type.nominal
                    {
                        true
                    }
                    else
                    {
                        false
                    }
                }
            }
            //  It’s possible for two locally-disjoint extensions to coalesce
            //  into a single global extension due to constraint dropping...
            {
                /// Protocols usually come with many features, so as a premature
                /// optimization, we group the features by protocol.
                let features:[Unidoc.Scalar: [Unidoc.Scalar]] = `extension`.features.reduce(
                    into: [:])
                {
                    //  The feature might have been declared in a different package!
                    //  This started happening when SSGC stopped emitting unqualified features
                    //  as this was previously handled in ``linkCultures``.
                    if  let f:Unidoc.Scalar = context.current.scalars.decls[$1],
                        let p:Unidoc.Scalar = context[f.package]?.scope(of: f)
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
                            where: { $0.culture == `extension`.culture })
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

            } (&self[.extends(s, where: conditions)])
        }

        return conformances
    }
}
extension Unidoc.Linker.Table<Unidoc.Extension>
{
    func peers(in edition:Unidoc.Edition) -> [Int32: Unidoc.Group]
    {
        self.table.values.reduce(into: [:])
        {
            for nested:Unidoc.Scalar in $1.nested
            {
                $0[nested.citizen] = $1.id.in(edition)
            }
        }
    }
}
