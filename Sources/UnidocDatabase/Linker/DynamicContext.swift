import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Symbols

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
    init(currentSnapshot:__owned Snapshot,
        upstreamSnapshots:__owned [Snapshot],
        upstreamSymbols:__shared UpstreamSymbols)
    {
        var byPackageIdentifier:[PackageIdentifier: SnapshotObject] = .init(
            minimumCapacity: upstreamSnapshots.count)

        var byPackage:[Int32: SnapshotObject] = .init(
            minimumCapacity: upstreamSnapshots.count)

        for snapshot:Snapshot in upstreamSnapshots
        {
            let object:SnapshotObject = .init(snapshot: snapshot, upstream: upstreamSymbols)

            byPackageIdentifier[snapshot.metadata.package] = object
            byPackage[snapshot.package] = object
        }

        self.init(
            byPackageIdentifier: byPackageIdentifier,
            byPackage: byPackage,
            current: .init(
                snapshot: currentSnapshot,
                upstream: upstreamSymbols))
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

    subscript(scalar address:GlobalAddress) -> SymbolGraph.Scalar?
    {
        self[address.package]?[scalar: address]?.scalar
    }

    func expand(_ address:GlobalAddress) -> [GlobalAddress]
    {
        var current:GlobalAddress = address
        var path:[GlobalAddress] = [current]
        //  This prevents us from getting stuck in an infinite loop if one of the
        //  documentation archives is malformed/malicious.
        var seen:Set<GlobalAddress> = [current]

        while   let next:GlobalAddress = self[current.package]?.scope(of: current),
                case nil = seen.update(with: next)
        {
            path.append(next)
            current = next
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

        var buffer:[DynamicResolutionGroup?] = .init(repeating: nil,
            count: self.current.graph.cultures.count)

        for (dependencies, cultures):([PackageIdentifier: Set<String>], [Int]) in groups
        {
            var codelinks:CodelinkResolver<GlobalAddress>.Table = .init()
            var imports:[ModuleIdentifier] = []

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

                self.populate(codelinks: &codelinks, filter: filter, from: object)
                imports += filter.sorted().map { object.snapshot.graph.namespaces[$0] }
            }

            let group:DynamicResolutionGroup = .init(codelinks: codelinks, imports: imports)
            for c:Int in cultures
            {
                buffer[c] = group
            }
        }
        //  We could probably also do this with
        // ``Array.init(unsafeUninitializedCapacity:initializingWith:)``,
        //  but that seems unnecessary here.
        return buffer.map { $0! }
    }
}
extension DynamicContext
{
    private
    func populate(
        codelinks:inout CodelinkResolver<GlobalAddress>.Table,
        filter:Set<Int>,
        from snapshot:SnapshotObject)
    {
        for (c, culture):(Int, SymbolGraph.Culture) in zip(
            snapshot.graph.cultures.indices,
            snapshot.graph.cultures) where
            filter.contains(c)
        {
            for namespace:SymbolGraph.Namespace in culture.namespaces
            {
                self.add(namespace: namespace, filter: filter, from: current, to: &codelinks)
            }
        }
    }

    private
    func add(namespace:SymbolGraph.Namespace,
        filter:Set<Int>,
        from snapshot:SnapshotObject,
        to codelinks:inout CodelinkResolver<GlobalAddress>.Table)
    {
        let qualifier:ModuleIdentifier = snapshot.graph.namespaces[namespace.index]
        for s:Int32 in namespace.range
        {
            let node:SymbolGraph.Node = snapshot.graph.nodes[s]
            let symbol:ScalarSymbol = snapshot.graph.symbols[s]

            guard let s:GlobalAddress = s * snapshot.projector
            else
            {
                continue
            }

            if  let citizen:SymbolGraph.Scalar = node.scalar
            {
                codelinks[qualifier, citizen.path].overload(with: .init(
                    target: .scalar(s),
                    phylum: citizen.phylum,
                    hash: .init(hashing: "\(symbol)")))
            }
            if  node.extensions.isEmpty
            {
                continue
            }
            //  Extension may extend a scalar from a different package.
            if  let outer:SymbolGraph.Scalar = node.scalar ?? self[scalar: s]
            {
                self.add(extensions: node.extensions,
                    extending: (s, outer, symbol),
                    filter: filter,
                    from: snapshot,
                    to: &codelinks)
            }
        }
    }
    private
    func add(extensions:[SymbolGraph.Extension],
        extending outer:
        (
            address:GlobalAddress,
            scalar:SymbolGraph.Scalar,
            symbol:ScalarSymbol
        ),
        filter:Set<Int>,
        from snapshot:SnapshotObject,
        to codelinks:inout CodelinkResolver<GlobalAddress>.Table)
    {
        for `extension`:SymbolGraph.Extension in extensions where
            !`extension`.features.isEmpty && filter.contains(`extension`.culture)
        {
            //  This can be completely different from the namespace of the extended type!
            let qualifier:ModuleIdentifier = snapshot.graph.namespaces[`extension`.namespace]
            for f:Int32 in `extension`.features
            {
                let symbol:VectorSymbol = .init(snapshot.graph.symbols[f],
                    self: outer.symbol)

                if  let f:GlobalAddress = f * snapshot.projector,
                    let inner:SymbolGraph.Scalar = self[scalar: f]
                {
                    codelinks[qualifier, outer.scalar.path, inner.path.last].overload(
                        with: .init(target: .vector(f, self: outer.address),
                            phylum: inner.phylum,
                            hash: .init(hashing: "\(symbol)")))
                }
            }
        }
    }
}
