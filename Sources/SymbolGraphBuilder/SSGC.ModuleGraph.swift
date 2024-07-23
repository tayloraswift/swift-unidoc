import PackageGraphs
import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC
{
    struct ModuleGraph
    {
        private
        var productPartitions:[Symbol.Product: [SymbolGraph.Module]] = [:]
        /// Note: the standard library is not modeled as part of the module graph, as its
        /// modules are assumed to be dependencies of every module in the module graph.
        private
        let standardLibrary:[SymbolGraph.Module]
        private
        let sparseEdges:[(PackageGraph.Vertex, PackageGraph.Vertex)]

        let package:PackageNode

        private
        init(standardLibrary:[SymbolGraph.Module],
            sparseEdges:[(PackageGraph.Vertex, PackageGraph.Vertex)],
            package:PackageNode)
        {
            self.standardLibrary = standardLibrary
            self.sparseEdges = sparseEdges
            self.package = package
        }
    }
}
extension SSGC.ModuleGraph
{
    init(standardLibrary:[SymbolGraph.Module],
        sparseEdges:[(SSGC.PackageGraph.Vertex, SSGC.PackageGraph.Vertex)],
        dependencies:[PackageNode],
        sink:PackageNode) throws
    {
        self.init(standardLibrary: standardLibrary,
            sparseEdges: sparseEdges,
            package: try sink.flattened(dependencies: dependencies))

        for node:PackageNode in dependencies
        {
            self.addPartitions(of: node)
        }

        self.addPartitions(of: self.package)
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
extension SSGC.ModuleGraph
{
    /// Returns all dependencies of the given module (including transitive dependencies),
    /// sorted in topological dependency order. The list begins with all the standard library
    /// modules.
    func dependencies(of module:__owned SymbolGraph.Module) throws -> [SymbolGraph.Module]
    {
        var dependencies:[Vertex] = module.dependencies.modules.map
        {
            .init(module: self.package.modules[$0], in: self.package.id)
        }
        for dependency:Symbol.Product in module.dependencies.products
        {
            guard
            let modules:[SymbolGraph.Module] = self.productPartitions[dependency]
            else
            {
                throw TargetNode.DependencyError.undefinedProduct(dependency)
            }

            for module:SymbolGraph.Module in modules
            {
                dependencies.append(.init(module: module, in: dependency.package))
            }
        }

        guard
        let dependencies:[Vertex] = dependencies.sortedTopologically(by: self.sparseEdges)
        else
        {
            throw DigraphCycleError<Vertex>.init()
        }

        var modules:[SymbolGraph.Module] = self.standardLibrary
        for dependency:Vertex in dependencies
        {
            modules.append(dependency.module)
        }
        return modules
    }

    /// Filters the given dependency pins, returning the dependencies that are actually used by
    /// at least one package product.
    func dependenciesUsed(pins:[SPM.DependencyPin]) throws -> [SymbolGraphMetadata.Dependency]
    {
        let dependenciesPinned:[SymbolGraphMetadata.Dependency] = try self.package.pin(to: pins)
        let dependenciesUsed:Set<Symbol.Package> = self.package.products.reduce(into: [])
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
