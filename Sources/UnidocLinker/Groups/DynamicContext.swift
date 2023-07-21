import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Symbols
import Unidoc

@frozen public
struct DynamicContext
{
    private
    let byPackageIdentifier:[PackageIdentifier: SnapshotObject]
    private
    let byPackage:[Int32: SnapshotObject]

    let current:SnapshotObject

    private
    init(
        byPackageIdentifier:[PackageIdentifier: SnapshotObject],
        byPackage:[Int32: SnapshotObject],
        current:SnapshotObject)
    {
        self.byPackageIdentifier = byPackageIdentifier
        self.byPackage = byPackage
        self.current = current
    }
}
extension DynamicContext
{
    public
    init(_ currentSnapshot:__owned Snapshot, dependencies:__owned [Snapshot])
    {
        //  Build a combined lookup table mapping upstream symbols to scalars.
        //  Because module names are unique within a build tree, there should
        //  be no collisions among mangled symbols.
        var upstream:UpstreamScalars = .init()

        for snapshot:Snapshot in dependencies
        {
            for (citizen, symbol):(Int32, Symbol.Decl) in snapshot.graph.citizens
            {
                upstream.citizens[symbol] = snapshot.zone + citizen
            }
            for (culture, symbol):(Int, ModuleIdentifier) in zip(
                snapshot.graph.cultures.indices,
                snapshot.graph.namespaces)
            {
                upstream.cultures[symbol] = snapshot.zone + culture * .module
            }
        }

        //  Build two indexes for fast lookup by package identifier and package number.
        var byPackageIdentifier:[PackageIdentifier: SnapshotObject] = .init(
            minimumCapacity: dependencies.count)

        var byPackage:[Int32: SnapshotObject] = .init(
            minimumCapacity: dependencies.count)

        for snapshot:Snapshot in dependencies
        {
            let object:SnapshotObject = .init(snapshot: snapshot, upstream: upstream)

            byPackageIdentifier[snapshot.metadata.package] = object
            byPackage[snapshot.package] = object
        }

        self.init(
            byPackageIdentifier: byPackageIdentifier,
            byPackage: byPackage,
            current: .init(
                snapshot: currentSnapshot,
                upstream: upstream))
    }
}
extension DynamicContext
{
    private
    subscript(dynamic package:PackageIdentifier) -> SnapshotObject?
    {
        self.current.snapshot.metadata.package == package ?
        nil : self.byPackageIdentifier[package]
    }
    subscript(package:PackageIdentifier) -> SnapshotObject?
    {
        self.current.snapshot.metadata.package == package ?
        self.current : self.byPackageIdentifier[package]
    }
    subscript(package:Int32) -> SnapshotObject?
    {
        self.current.snapshot.package == package ?
        self.current : self.byPackage[package]
    }
}
extension DynamicContext
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
            if  let next:Unidoc.Scalar = self[current.package]?.scope(of: current),
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
extension DynamicContext
{
    /// Builds a codelink resolution table
    func groups() -> [DynamicClientGroup]
    {
        //  Some cultures might share the same set of upstream product dependencies.
        //  So, as an optimization, we group cultures together that use the same
        //  resolution tables.
        var groups:[[PackageIdentifier: Set<String>]: [Int]] = [:]
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            self.current.graph.cultures.indices,
            self.current.graph.cultures)
        {
            print("\(culture.module.id): \(culture.module.dependencies)")

            //  This dictionary is a dictionary key itself! Be not afraid.
            var products:[PackageIdentifier: Set<String>] = [:]
            for product:ProductIdentifier in culture.module.dependencies.products
            {
                products[product.package, default: []].update(with: product.name)
            }
            //  If we had `n` cultures, we could have fewer than `n` groups.
            groups[products, default: []].append(c)
        }

        return .init(unsafeUninitializedCapacity: self.current.graph.cultures.count)
        {
            for (dependencies, cultures):([PackageIdentifier: Set<String>], [Int]) in groups
            {
                var group:DynamicClientGroup = .init(nodes: self.current.graph.nodes.count)
                //  We already
                if  let swift:SnapshotObject = self[dynamic: .swift]
                {
                    group.add(snapshot: swift, context: self, filter: nil)
                }
                for (package, products):(PackageIdentifier, Set<String>) in
                    dependencies.sorted(by: { $0.key < $1.key })
                {
                    guard let object:SnapshotObject = self[dynamic: package]
                    else
                    {
                        continue
                    }

                    var filter:Set<Int> = []
                    for product:ProductDetails in object.snapshot.metadata.products where
                        products.contains(product.name)
                    {
                        filter.formUnion(product.cultures)
                    }

                    group.add(snapshot: object, context: self, filter: filter)
                }

                for c:Int in cultures
                {
                    $0.initializeElement(at: c, to: group)
                }
            }

            $1 = $0.count
        }
    }
}
