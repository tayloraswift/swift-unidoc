import CodelinkResolution
import SemanticVersions
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import UnidocDiagnostics
import UnidocRecords

@available(*, deprecated, renamed: "DynamicLinker")
public
typealias DynamicContext = DynamicLinker

@frozen public
struct DynamicLinker:~Copyable
{
    var diagnostics:DiagnosticContext<DynamicSymbolicator>

    private
    let byPackageIdentifier:[Symbol.Package: Snapshot]
    private
    let byPackage:[Unidoc.Package: Snapshot]

    let current:Snapshot

    private
    init(
        byPackageIdentifier:[Symbol.Package: Snapshot],
        byPackage:[Unidoc.Package: Snapshot],
        current:Snapshot)
    {
        self.byPackageIdentifier = byPackageIdentifier
        self.byPackage = byPackage
        self.current = current

        self.diagnostics = .init()
    }
}
extension DynamicLinker
{
    public
    init(_ currentSnapshot:Unidoc.Snapshot, dependencies:borrowing [Unidoc.Snapshot])
    {
        //  Build a combined lookup table mapping upstream symbols to scalars.
        //  Because module names are unique within a build tree, there should
        //  be no collisions among mangled symbols.
        var upstream:UpstreamScalars = .init()

        for snapshot:Unidoc.Snapshot in copy dependencies
        {
            for (citizen, symbol):(Int32, Symbol.Decl) in snapshot.graph.decls.citizens
            {
                upstream.citizens[symbol] = snapshot.id + citizen
            }
            for (culture, symbol):(Int, Symbol.Module) in zip(
                snapshot.graph.cultures.indices,
                snapshot.graph.namespaces)
            {
                upstream.cultures[symbol] = snapshot.id + culture * .module
            }
        }

        //  Build two indexes for fast lookup by package identifier and package number.
        var byPackageIdentifier:[Symbol.Package: Snapshot] = .init(
            minimumCapacity: dependencies.count)

        var byPackage:[Unidoc.Package: Snapshot] = .init(
            minimumCapacity: dependencies.count)

        for snapshot:Unidoc.Snapshot in copy dependencies
        {
            let snapshot:Snapshot = .init(snapshot: snapshot, upstream: upstream)

            byPackageIdentifier[snapshot.metadata.package] = snapshot
            byPackage[snapshot.id.package] = snapshot
        }

        self.init(
            byPackageIdentifier: byPackageIdentifier,
            byPackage: byPackage,
            current: .init(
                snapshot: currentSnapshot,
                upstream: upstream))
    }
}
extension DynamicLinker
{
    public mutating
    func link() -> Mesh
    {
        var tables:Tables = .init(context: consume self)

        let cultures:[Volume.Vertex.Culture] = tables.link()

        let articles:[Volume.Vertex.Article] = tables.articles
        let decls:[Volume.Vertex.Decl] = tables.decls
        let groups:Volume.Groups = tables.groups
        let extensions:Extensions = tables.extensions

        self = (consume tables).context

        return .init(extensions: extensions,
            articles: articles,
            cultures: cultures,
            decls: decls,
            groups: groups,
            context: self)
    }

    public consuming
    func status() -> some Diagnostics
    {
        let diagnostics:DiagnosticContext<DynamicSymbolicator> = self.diagnostics
        let symbols:DynamicSymbolicator = .init(context: self,
            root: self.current.metadata.root)

        return diagnostics.with(symbolicator: symbols)
    }
}
extension DynamicLinker
{
    private
    subscript(dynamic package:Symbol.Package) -> Snapshot?
    {
        self.current.metadata.package == package ?
        nil : self.byPackageIdentifier[package]
    }
    subscript(package:Symbol.Package) -> Snapshot?
    {
        self.current.metadata.package == package ?
        self.current : self.byPackageIdentifier[package]
    }
    subscript(package:Unidoc.Package) -> Snapshot?
    {
        self.current.id.package == package ?
        self.current : self.byPackage[package]
    }
}
extension DynamicLinker
{
    func expand(_ vector:(Unidoc.Scalar, Unidoc.Scalar), to length:Int) -> [Unidoc.Scalar]
    {
        self.expand(vector.0, to: length - 1) + [vector.1]
    }
    func expand(_ scalar:Unidoc.Scalar, to length:Int = .max) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<Unidoc.Scalar> = [current]

        for _:Int in 1 ..< max(1, length)
        {
            if  case let next? = self[current.package]?.scope(of: current),
                case nil = seen.update(with: next)
            {
                path.append(next)
                current = next
            }
            else
            {
                break
            }
        }

        return path.reversed()
    }
}
extension DynamicLinker
{
    public
    func dependencies() -> [Volume.Metadata.Dependency]
    {
        var dependencies:[Volume.Metadata.Dependency] = []
            dependencies.reserveCapacity(self.current.metadata.dependencies.count + 1)

        if  self.current.metadata.package != .swift,
            let swift:Snapshot = self[.swift]
        {
            dependencies.append(.init(symbol: .swift,
                requirement: nil,
                resolution: nil,
                pinned: swift.id))
        }
        for dependency:SymbolGraphMetadata.Dependency in self.current.metadata.dependencies
        {
            dependencies.append(.init(symbol: dependency.package,
                requirement: dependency.requirement,
                resolution: dependency.version.release,
                pinned: self[dependency.package]?.id))
        }

        return dependencies
    }

    func modules() -> [SymbolGraph.ModuleContext]
    {
        //  Some cultures might share the same set of upstream product dependencies.
        //  So, as an optimization, we group cultures together that use the same
        //  resolution tables.
        var groups:[[Symbol.Package: Set<String>]: [Int]] = [:]
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            self.current.cultures.indices,
            self.current.cultures)
        {
            print("\(culture.module.id): \(culture.module.dependencies)")

            //  This dictionary is a dictionary key itself! Be not afraid.
            var products:[Symbol.Package: Set<String>] = [:]
            for product:Symbol.Product in culture.module.dependencies.products
            {
                products[product.package, default: []].update(with: product.name)
            }
            //  If we had `n` cultures, we could have fewer than `n` groups.
            groups[products, default: []].append(c)
        }

        return .init(unsafeUninitializedCapacity: self.current.cultures.count)
        {
            for (dependencies, cultures):([Symbol.Package: Set<String>], [Int]) in groups
            {
                var shared:SymbolGraph.ModuleContext = .init(
                    nodes: self.current.scalars.decls[self.current.decls.nodes.indices])

                if  let swift:Snapshot = self[dynamic: .swift]
                {
                    shared.add(snapshot: swift, context: self, filter: nil)
                }
                for (package, products):(Symbol.Package, Set<String>) in
                    dependencies.sorted(by: { $0.key < $1.key })
                {
                    guard
                    let snapshot:Snapshot = self[dynamic: package]
                    else
                    {
                        continue
                    }

                    var filter:Set<Int> = []
                    for product:SymbolGraphMetadata.Product in snapshot.metadata.products
                        where products.contains(product.name)
                    {
                        filter.formUnion(product.cultures)
                    }

                    shared.add(snapshot: snapshot, context: self, filter: filter)
                }

                for c:Int in cultures
                {
                    $0.initializeElement(at: c, to: shared)
                }
            }

            $1 = $0.count
        }
    }
}
extension DynamicLinker
{
    mutating
    func simplify(conformances:inout [ProtocolConformance<Int>],
        of subject:Unidoc.Scalar,
        to protocol:Unidoc.Scalar)
    {
        /// The set of local package cultures in which this protocol conformance
        /// exists, either conditionally or unconditionally.
        ///
        /// It is valid (but totally demented) for a package to declare the same
        /// conformance in multiple modules, as long as they never intersect in
        /// a build tree.
        let extancy:Set<Int> = conformances.reduce(into: []) { $0.insert($1.culture) }

        //  Group conformances to this protocol by culture.
        let segregated:[Int: [[GenericConstraint<Unidoc.Scalar?>]]] = conformances.reduce(
            into: [:])
        {
            let module:SymbolGraph.Module = self.current.cultures[$1.culture].module
            for c:Int in module.dependencies.modules where
                c != $1.culture && extancy.contains(c)
            {
                //  Another module in this package already declares this
                //  conformance, and the `$1.culture` depends on it!
                return
            }

            $0[$1.culture, default: []].append($1.conditions)
        }

        //  A type can only conform to a protocol once in a culture,
        //  so we need to pick the most general set of generic constraints.
        //
        //  For example, `Optional<T>` conforms to `Equatable` where
        //  `T:Equatable`, but it also conforms to `Equatable` where
        //  `T:Hashable`, because if `T` is ``Hashable`` then it is also
        //  ``Equatable``. So that conformance is redundant.
        let reduced:[Int: [GenericConstraint<Unidoc.Scalar?>]] = segregated.mapValues
        {
            //  Swift does not have conditional disjunctions for protocol
            //  conformances. So the most general constraint list must be
            //  (one of) the shortest.
            var shortest:[[GenericConstraint<Unidoc.Scalar?>]] = []
            var length:Int = .max
            for constraints:[GenericConstraint<Unidoc.Scalar?>] in $0
            {
                if      constraints.count <  length
                {
                    shortest = [constraints]
                    length = constraints.count
                }
                else if constraints.count == length
                {
                    shortest.append(constraints)
                }
            }
            //  The array is always non-empty because `$0` itself is always
            //  non-empty, because it was created by appending to
            //  ``Dictionary.subscript(_:default:)``.
            if  shortest.count == 1
            {
                return shortest[0]
            }

            let constraints:Set<GenericConstraint<Unidoc.Scalar?>> = .init(
                shortest.joined())
            let reduced:Set<GenericConstraint<Unidoc.Scalar?>> = constraints.filter
            {
                switch $0
                {
                case .where(_,             is: .equal,   to: _):
                    //  Same-type constraints are never redundant.
                    return true

                case .where(let parameter, is: let what, to: let type):
                    if  case .nominal(let type?) = type,
                        let snapshot:Snapshot = self[type.package],
                        let local:[Int32] = snapshot.decls[type.citizen]?.decl?.superforms
                    {
                        for local:Int32 in local
                        {
                            //  If the constraint is `T:Hashable`, `Hashable:Equatable`,
                            //  and `T:Equatable` exists in the constraint set, then this
                            //  constraint is redundant.
                            if  let supertype:Unidoc.Scalar = snapshot.scalars.decls[local],
                                    supertype != type,
                                    constraints.contains(.where(parameter,
                                        is: what,
                                        to: .nominal(supertype)))
                            {
                                return false
                            }
                        }
                    }
                    return true
                }
            }
            //  We shouldn’t have fewer total constraints than we started with,
            //  otherwise that means some of the constraint lists had redundancies
            //  within themselves, and the Swift compiler should have already
            //  removed those.
            //
            //  By the same reasoning, at least one of the constraint lists should
            //  contain exactly the same constraints as the reduced set. We don’t
            //  return the set itself, because this implementation does not know
            //  anything about canonical constraint ordering.
            let ordered:[[GenericConstraint<Unidoc.Scalar?>]] = shortest.filter
            {
                $0.allSatisfy(reduced.contains(_:))
            }
            if  ordered.count >= 1,
                ordered[1...].allSatisfy({ $0 == ordered[0] })
            {
                return ordered[0]
            }
            else
            {
                diagnostics[nil] = ConstraintReductionError.init(invalid: ordered,
                    minimal: [_].init(reduced),
                    subject: subject,
                    protocol: `protocol`)
                //  See note above about non-emptiness.
                return shortest.first!
            }
        }

        //  Conformances should now be unique per culture.
        conformances = reduced.map
        {
            .init(conditions: $0.value, culture: $0.key)
        }

        conformances.sort
        {
            $0.culture < $1.culture
        }
    }

    mutating
    func resolving<Success>(
        namespace:Symbol.Module,
        module:SymbolGraph.ModuleContext,
        scope:[String] = [],
        with yield:(inout DynamicResolver) throws -> Success) rethrows -> Success
    {
        var resolver:DynamicResolver = .init(
            codelinks: .init(table: module.codelinks, scope: .init(
                namespace: namespace,
                imports: module.imports,
                path: scope)),
            context: consume self)

        do
        {
            let success:Success = try yield(&resolver)
            self = (consume resolver).context
            return success
        }
        catch let error
        {
            self = (consume resolver).context
            throw error
        }
    }
}

extension DynamicLinker
{
    func assemble(extension:Extension, signature:ExtensionSignature) -> Volume.Group.Extension
    {
        let prefetch:[Unidoc.Scalar] = []
        //  TODO: compute tertiary scalars

        return .init(id: `extension`.id,
            conditions: signature.conditions,
            culture: self.current.id + signature.culture,
            scope: signature.extends,
            conformances: self.sort(lexically: `extension`.conformances),
            features: self.sort(lexically: `extension`.features),
            nested: self.sort(lexically: `extension`.nested),
            subforms: self.sort(lexically: `extension`.subforms),
            prefetch: prefetch,
            overview: `extension`.overview,
            details: `extension`.details)
    }
}
extension DynamicLinker
{
    /// Get the sort-priority of a declaration.
    func priority(of decl:Unidoc.Scalar) -> SortPriority?
    {
        self[decl.package]?.priority(of: decl)
    }

    func sort(lexically decls:consuming [Unidoc.Scalar]) -> [Unidoc.Scalar]
    {
        decls.sort
        {
            switch (self.priority(of: $0), self.priority(of: $1))
            {
            case (nil, nil):            return $0 < $1
            case (nil,  _?):            return true
            case ( _?, nil):            return false
            case (let lhs?, let rhs?):  return lhs < rhs
            }
        }

        return decls
    }
}
