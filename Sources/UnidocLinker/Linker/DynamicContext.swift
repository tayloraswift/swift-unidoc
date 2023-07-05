import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
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
    init(currentSnapshot:__owned Snapshot,
        upstreamSnapshots:__owned [Snapshot],
        upstreamScalars:__shared UpstreamScalars)
    {
        var byPackageIdentifier:[PackageIdentifier: SnapshotObject] = .init(
            minimumCapacity: upstreamSnapshots.count)

        var byPackage:[Int32: SnapshotObject] = .init(
            minimumCapacity: upstreamSnapshots.count)

        for snapshot:Snapshot in upstreamSnapshots
        {
            let object:SnapshotObject = .init(snapshot: snapshot, upstream: upstreamScalars)

            byPackageIdentifier[snapshot.metadata.package] = object
            byPackage[snapshot.package] = object
        }

        self.init(
            byPackageIdentifier: byPackageIdentifier,
            byPackage: byPackage,
            current: .init(
                snapshot: currentSnapshot,
                upstream: upstreamScalars))
    }
}
extension DynamicContext
{
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
    func expand(_ vector:(Unidoc.Scalar, Unidoc.Scalar), to length:UInt32) -> [Unidoc.Scalar]
    {
        self.expand(vector.0, to: length - 1) + [vector.1]
    }
    func expand(_ scalar:Unidoc.Scalar, to length:UInt32 = .max) -> [Unidoc.Scalar]
    {
        var current:Unidoc.Scalar = scalar
        var path:[Unidoc.Scalar] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<Unidoc.Scalar> = [current]

        for _:UInt32 in 1 ..< max(1, length)
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
    func groups() -> [DynamicResolutionGroup]
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

            var products:[PackageIdentifier: Set<String>] = [:]
            for product:ProductIdentifier in culture.module.dependencies.products
            {
                products[product.package, default: []].update(with: product.name)
            }

            groups[products, default: []].append(c)
        }

        return .init(unsafeUninitializedCapacity: self.current.graph.cultures.count)
        {
            for (dependencies, cultures):([PackageIdentifier: Set<String>], [Int]) in groups
            {
                var group:DynamicResolutionGroup = .init()

                if  let swift:SnapshotObject = self[.swift]
                {
                    group.add(snapshot: swift, context: self, filter: nil)
                }
                for (package, products):(PackageIdentifier, Set<String>) in
                    dependencies.sorted(by: { $0.key < $1.key })
                {
                    guard let object:SnapshotObject = self[package]
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
