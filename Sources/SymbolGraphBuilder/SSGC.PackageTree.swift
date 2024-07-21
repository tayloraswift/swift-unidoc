import PackageGraphs
import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC
{
    struct PackageTree
    {
        private(set)
        var productPartitions:[Symbol.Product: [SymbolGraph.Module]] = [:]

        private
        let nodes:[Symbol.Package: PackageNode]
        let sink:PackageNode

        private
        init(nodes:[Symbol.Package: PackageNode], sink:PackageNode)
        {
            self.productPartitions = [:]
            self.nodes = nodes
            self.sink = sink
        }
    }
}
extension SSGC.PackageTree
{
    init(dependencies:[PackageNode], sink:PackageNode) throws
    {
        let sink:PackageNode = try sink.flattened(dependencies: dependencies)
        let nodes:[Symbol.Package: PackageNode] = dependencies.reduce(into: [sink.id: sink])
        {
            $0[$1.id] = $1
        }

        self.init(nodes: nodes, sink: sink)

        for node:PackageNode in dependencies
        {
            self.addPartitions(of: node)
        }

        self.addPartitions(of: self.sink)
    }

    private mutating
    func addPartitions(of node:PackageNode)
    {
        for product:SymbolGraph.Product in node.products
        {
            let id:Symbol.Product = .init(name: product.name, package: node.id)
            self.productPartitions[id] = product.cultures.map { node.modules[$0] }
        }
    }
}
extension SSGC.PackageTree
{
    /// Filters the given dependency pins, returning the dependencies that are actually used by
    /// at least one package product.
    func dependenciesUsed(pins:[SPM.DependencyPin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let dependenciesPinned:[SymbolGraphMetadata.Dependency] = try self.sink.pin(to: pins)
        let dependenciesUsed:Set<Symbol.Package> = self.sink.products.reduce(into: [])
        {
            guard
            case .library = $1.type
            else
            {
                return
            }
            for dependency:Symbol.Product in $1.dependencies
            {
                $0.insert(dependency.package)
            }
        }

        return dependenciesPinned.filter { dependenciesUsed.contains($0.package.name) }
    }
}
