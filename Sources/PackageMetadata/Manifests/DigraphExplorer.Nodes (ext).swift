import PackageGraphs
import SymbolGraphs

extension DigraphExplorer<TargetNode>.Nodes
{
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by the given product.
    func included(by product:PackageManifest.Product,
        on platform:SymbolGraphMetadata.Platform) throws -> Set<String>
    {
        var explorer:DigraphExplorer<TargetNode> = .init(nodes: self)
        for name:String in product.targets
        {
            try explorer.explore(node: name)
        }
        let included:[String: TargetNode] = try explorer.conquer
        {
            for dependency:String in $1.dependencies.targets(on: platform)
            {
                try $0.explore(node: dependency)
            }
        }
        return .init(included.keys)
    }
    /// Returns *all* targets in the index that are included, directly or indirectly,
    /// by at least one of the given products. The targets are canonically ordered by
    /// their internal dependency relationships; targets that appear later in the list
    /// depend only on targets that appear before them in the list.
    func included(by products:[PackageManifest.Product],
        on platform:SymbolGraphMetadata.Platform) throws -> [TargetNode]
    {
        var explorer:DigraphExplorer<TargetNode> = .init(nodes: self)

        for product:PackageManifest.Product in products
        {
            for name:String in product.targets
            {
                try explorer.explore(node: name)
            }
        }
        /// The list of targets that *directly* depend on each (explored) target.
        var consumers:[String: [TargetNode]] = [:]
        let included:[String: TargetNode] = try explorer.conquer
        {
            // need to sort dependency set to make topological sort deterministic
            for name:String in $1.dependencies.targets(on: platform).sorted()
            {
                consumers[name, default: []].append($1)
                try $0.explore(node: name)
            }
        }
        if  let targets:[TargetNode] = TargetNode.order(
                topologically: included,
                consumers: &consumers)
        {
            return targets
        }
        else
        {
            throw DigraphCycleError<TargetNode>.init()
        }
    }
}
