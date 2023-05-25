import PackageGraphs

extension PackageMap
{
    /// An index of package targets.
    struct Targets:Sendable
    {
        private
        let index:[String: PackageManifest.Target]

        private
        init(index:[String: PackageManifest.Target])
        {
            self.index = index
        }
    }
}
extension PackageMap.Targets
{
    init(indexing targets:[PackageManifest.Target]) throws
    {
        self.init(index: try .init(targets.lazy.map { ($0.name, $0) })
        {
            throw PackageManifest.TargetError.duplicate($1.name)
        })
    }

    func callAsFunction(_ name:String) throws -> PackageManifest.Target
    {
        if  let target:PackageManifest.Target = self.index[name]
        {
            return target
        }
        else
        {
            throw PackageManifest.TargetError.undefined(name)
        }
    }
}
extension PackageMap.Targets
{
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by the given target.
    func included(by target:PackageManifest.Target,
        on platform:PlatformIdentifier) throws -> Set<String>
    {
        var explorer:PackageMap.TargetExplorer = .init(targets: self)
            explorer.explore(target: target)
        let included:[String: PackageManifest.Target] = try explorer.conquer
        {
            for dependency:String in $1.dependencies.targets(on: platform)
            {
                try $0.explore(target: dependency)
            }
        }
        return .init(included.keys)
    }
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by the given product.
    func included(by product:PackageManifest.Product,
        on platform:PlatformIdentifier) throws -> Set<String>
    {
        var explorer:PackageMap.TargetExplorer = .init(targets: self)
        for name:String in product.targets
        {
            try explorer.explore(target: name)
        }
        let included:[String: PackageManifest.Target] = try explorer.conquer
        {
            for dependency:String in $1.dependencies.targets(on: platform)
            {
                try $0.explore(target: dependency)
            }
        }
        return .init(included.keys)
    }
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by at least one of the given products. The targets are canonically ordered by
    /// their internal dependency relationships; targets that appear later in the list
    /// depend only on targets that appear before them in the list.
    func included(by products:[PackageManifest.Product],
        on platform:PlatformIdentifier) throws -> [PackageManifest.Target]
    {
        var explorer:PackageMap.TargetExplorer = .init(targets: self)

        for product:PackageManifest.Product in products
        {
            for name:String in product.targets
            {
                try explorer.explore(target: name)
            }
        }
        /// The list of targets that *directly* depend on each (explored) target.
        var consumers:[String: [PackageManifest.Target]] = [:]
        let included:[String: PackageManifest.Target] = try explorer.conquer
        {
            // need to sort dependency set to make topological sort deterministic
            for name:String in $1.dependencies.targets(on: platform).sorted()
            {
                consumers[name, default: []].append($1)
                try $0.explore(target: name)
            }
        }
        if  let targets:[PackageManifest.Target] = PackageManifest.order(
                topologically: included,
                consumers: &consumers)
        {
            return targets
        }
        else
        {
            throw PackageManifestError.dependencyCycle
        }
    }
}
