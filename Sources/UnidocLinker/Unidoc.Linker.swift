import CodelinkResolution
import Codelinks
import SemanticVersions
import Signatures
import SymbolGraphs
import Symbols
import Unidoc
import SourceDiagnostics
import UnidocRecords

@available(*, deprecated, renamed: "Unidoc.Linker")
public
typealias DynamicContext = Unidoc.Linker

@available(*, deprecated, renamed: "Unidoc.Linker")
public
typealias DynamicLinker = Unidoc.Linker


extension Unidoc
{
    //  https://github.com/apple/swift/issues/72136
    @frozen public
    struct Linker//:~Copyable
    {
        var diagnostics:Diagnostics<Unidoc.Symbolicator>

        private
        let byPackageName:[Symbol.Package: Graph]
        private
        let byPackage:[Package: Graph]

        let current:Graph

        /// The set of all nodes in the current graph. These are the nodes being linked; all
        /// other nodes in this structure are merely used for context.
        let nodes:Set<Unidoc.Scalar>

        private
        init(
            byPackageName:[Symbol.Package: Graph],
            byPackage:[Package: Graph],
            current:Graph,
            nodes:Set<Unidoc.Scalar>)
        {
            self.byPackageName = byPackageName
            self.byPackage = byPackage
            self.current = current
            self.nodes = nodes

            self.diagnostics = .init()
        }
    }
}

extension Unidoc.Linker
{
    public
    init(
        linking primary:consuming SymbolGraphObject<Unidoc.Edition>,
        against others:borrowing [SymbolGraphObject<Unidoc.Edition>])
    {
        //  Build a combined lookup table mapping upstream symbols to scalars.
        //  Because module names are unique within a build tree, there should
        //  be no collisions among mangled symbols.
        var upstream:UpstreamScalars = .init()

        for other:SymbolGraphObject<Unidoc.Edition> in copy others
        {
            for (citizen, symbol):(Int32, Symbol.Decl) in other.graph.decls.citizens
            {
                upstream.citizens[symbol] = other.id + citizen
            }
            for (culture, symbol):(Int, Symbol.Module) in zip(
                other.graph.cultures.indices,
                other.graph.namespaces)
            {
                upstream.cultures[symbol] = other.id + culture * .module
            }
        }

        //  Build two indexes for fast lookup by package identifier and package number.
        var byPackageName:[Symbol.Package: Graph] = .init(
            minimumCapacity: others.count)

        var byPackage:[Unidoc.Package: Graph] = .init(
            minimumCapacity: others.count)

        for other:SymbolGraphObject<Unidoc.Edition> in copy others
        {
            let other:Graph = .init(other, upstream: upstream)

            byPackageName[other.metadata.package.name] = other
            byPackage[other.id.package] = other
        }

        let current:Graph = .init(primary, upstream: upstream)

        self.init(
            byPackageName: byPackageName,
            byPackage: byPackage,
            current: current,
            nodes: current.scalars.decls[current.decls.nodes.indices].reduce(into: [])
            {
                if  let s:Unidoc.Scalar = $1
                {
                    $0.insert(s)
                }
            })
    }
}
extension Unidoc.Linker
{
    public mutating
    func link() -> Mesh
    {
        var tables:Tables = .init(context: consume self)

        let conformances:Table<Unidoc.Conformers> = tables.linkConformingTypes()
        let products:[Unidoc.ProductVertex] = tables.linkProducts()
        let cultures:[Unidoc.CultureVertex] = tables.linkCultures()

        let articles:[Unidoc.ArticleVertex] = tables.articles
        let decls:[Unidoc.DeclVertex] = tables.decls
        let groups:Unidoc.Volume.Groups = tables.groups
        let extensions:Table<Unidoc.Extension> = tables.extensions

        self = (consume tables).context

        return .init(
            conformances: conformances,
            extensions: extensions,
            products: products,
            cultures: cultures,
            articles: articles,
            decls: decls,
            groups: groups,
            linker: self)
    }

    public consuming
    func status() -> DiagnosticMessages
    {
        let diagnostics:Diagnostics<Unidoc.Symbolicator> = self.diagnostics
        let symbols:Unidoc.Symbolicator = .init(context: self,
            root: self.current.metadata.root)

        return diagnostics.symbolicated(with: symbols)
    }
}
extension Unidoc.Linker
{
    private
    subscript(dynamic package:Symbol.Package) -> Graph?
    {
        self.current.metadata.package.name == package ?
        nil : self.byPackageName[package]
    }
    subscript(package:Symbol.Package) -> Graph?
    {
        self.current.metadata.package.name == package ?
        self.current : self.byPackageName[package]
    }
    subscript(package:Unidoc.Package) -> Graph?
    {
        self.current.id.package == package ?
        self.current : self.byPackage[package]
    }
}
extension Unidoc.Linker
{
    func format(codelink:Codelink,
        to target:CodelinkResolver<Unidoc.Scalar>.Overload.Target?) -> Unidoc.Outline
    {
        /// This looks a lot like a stem, but it always uses spaces, never tabs.
        /// Its purpose is to allow splitting the path into words without parsing the
        /// Swift language grammar.
        var path:String { codelink.path.visible.joined(separator: " ") }
        var text:String { codelink.path.visible.joined(separator: ".") }
        let length:Int = codelink.path.visible.count

        switch target
        {
        case nil:
            return .text(text)

        case .scalar(let scalar)?:
            return .path(path, self.expand(scalar, to: length))

        case .vector(let feature, self: let heir)?:
            return .path(path, self.expand((heir, feature), to: length))
        }
    }

    func expand(_ vector:(Unidoc.Scalar, Unidoc.Scalar), to length:Int) -> [Unidoc.Scalar]
    {
        self.expand(vector.0, to: length - 1) + [vector.1]
    }
    func expand(_ scalar:Unidoc.Scalar, to length:Int) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<Unidoc.Scalar> = [current]

        for _:Int in 1 ..< max(1, length)
        {
            guard
            let next:Unidoc.Scalar = self[current.package]?.ancestor(of: current),
            case nil = seen.update(with: next)
            else
            {
                break
            }

            path.append(next)
            current = next
        }

        return path.reversed()
    }
    /// This function looks very similar to `expand(_:to:)`, but it never includes the module
    /// namespace!
    func expand(_ scalar:Unidoc.Scalar) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        var seen:Set<Unidoc.Scalar> = [current]

        while let next:Unidoc.Scalar = self[current.package]?.scope(of: current),
            case nil = seen.update(with: next)
        {

            path.append(next)
            current = next
        }

        return path.reversed()
    }
}
extension Unidoc.Linker
{
    public
    func dependencies(pinned:[Unidoc.Edition?]) -> [Unidoc.VolumeMetadata.Dependency]
    {
        var dependencies:[Unidoc.VolumeMetadata.Dependency] = []
            dependencies.reserveCapacity(self.current.metadata.dependencies.count + 1)

        if  self.current.metadata.package.name != .swift,
            let swift:Graph = self[.swift]
        {
            dependencies.append(.init(exonym: .swift,
                requirement: nil,
                resolution: nil,
                pin: .linked(swift.id)))
        }
        for (id, dependency):(Unidoc.Edition?, SymbolGraphMetadata.Dependency) in zip(pinned,
            self.current.metadata.dependencies)
        {
            let pin:Unidoc.VolumeMetadata.DependencyPin?

            if  let id:Unidoc.Edition = self[dependency.package.name]?.id
            {
                pin = .linked(id)
            }
            else if
                let id:Unidoc.Edition
            {
                pin = .pinned(id)
            }
            else
            {
                pin = nil
            }

            dependencies.append(.init(exonym: dependency.package.name,
                requirement: dependency.requirement,
                resolution: dependency.version.release,
                pin: pin))
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
                let shared:SymbolGraph.ModuleContext = .init
                {
                    if  let swift:Graph = self[dynamic: .swift]
                    {
                        $0.add(snapshot: swift, context: self, filter: nil)
                    }
                    for (package, products):(Symbol.Package, Set<String>) in
                        dependencies.sorted(by: { $0.key < $1.key })
                    {
                        guard
                        let snapshot:Graph = self[dynamic: package]
                        else
                        {
                            continue
                        }

                        var filter:Set<Int> = []
                        for product:SymbolGraph.Product in snapshot.metadata.products
                            where products.contains(product.name)
                        {
                            filter.formUnion(product.cultures)
                        }

                        $0.add(snapshot: snapshot, context: self, filter: filter)
                    }
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
extension Unidoc.Linker
{
    mutating
    func simplify(conformances:inout [Unidoc.ExtensionConditions],
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

            $0[$1.culture, default: []].append($1.constraints)
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
                        let snapshot:Graph = self[type.package],
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
                self.diagnostics[nil] = ConstraintReductionError.init(invalid: ordered,
                    minimal: [_].init(reduced),
                    subject: subject,
                    protocol: `protocol`)
                //  See note above about non-emptiness.
                return shortest.first!
            }
        }

        //  Conformances should now be unique per culture.
        conformances = reduced.map { .init(constraints: $0.value, culture: $0.key) }
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
        with yield:(inout Unidoc.Resolver) throws -> Success) rethrows -> Success
    {
        var resolver:Unidoc.Resolver = .init(
            codelinks: .init(table: module.codelinks, scope: .init(
                namespace: namespace,
                imports: module.imports,
                path: scope)),
            caseless: .init(table: module.caseless, scope: .init(
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
extension Unidoc.Linker
{
    func sort<Decl, Priority>(_ decls:consuming [Decl], by _:Priority.Type) -> [Decl]
        where Decl:Identifiable<Unidoc.Scalar>, Priority:Unidoc.SortPriority
    {
        decls.sort
        {
            switch (Priority.of(decl: $0.id, in: self), Priority.of(decl: $1.id, in: self))
            {
            case (nil, nil):        $0.id < $1.id
            case (nil,  _?):        true
            case ( _?, nil):        false
            case (let a?, let b?):  a  <  b
            }
        }

        return decls
    }
}
