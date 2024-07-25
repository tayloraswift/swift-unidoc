import PackageGraphs
import PackageMetadata
import SymbolGraphs
import Symbols

extension SSGC
{
    struct ModuleGraph
    {
        private
        var productPartitions:[Symbol.Product: [ModuleLayout]] = [:]
        /// Note: the standard library is not modeled as part of the module graph, as its
        /// modules are assumed to be dependencies of every module in the module graph.
        private
        let standardLibrary:[ModuleLayout]
        private
        let sparseEdges:[(PackageGraph.Vertex, PackageGraph.Vertex)]

        let sinkLayout:PackageLayout
        let sink:PackageNode

        private
        init(standardLibrary:[ModuleLayout],
            sparseEdges:[(PackageGraph.Vertex, PackageGraph.Vertex)],
            sinkLayout:PackageLayout,
            sink:PackageNode)
        {
            self.standardLibrary = standardLibrary
            self.sparseEdges = sparseEdges
            self.sinkLayout = sinkLayout
            self.sink = sink
        }
    }
}
extension SSGC.ModuleGraph
{
    init(standardLibrary:[SSGC.ModuleLayout],
        sparseEdges:[(SSGC.PackageGraph.Vertex, SSGC.PackageGraph.Vertex)],
        dependencies:[PackageNode],
        sink:PackageNode) throws
    {
        let densified:PackageNode = try sink.flattened(dependencies: dependencies)
        self.init(standardLibrary: standardLibrary,
            sparseEdges: sparseEdges,
            sinkLayout: try .init(scanning: densified),
            sink: consume densified)

        for node:PackageNode in dependencies
        {
            let dependencyLayout:SSGC.PackageLayout = try .init(scanning: node)
            self.addPartitions(of: dependencyLayout.cultures, in: node)
        }

        self.addPartitions(of: self.sinkLayout.cultures, in: self.sink)
    }

    private mutating
    func addPartitions(of moduleLayouts:[SSGC.ModuleLayout], in package:PackageNode)
    {
        for product:SymbolGraph.Product in package.products
        {
            let id:Symbol.Product = .init(name: product.name, package: package.id)
            self.productPartitions[id] = product.cultures.map { moduleLayouts[$0] }
        }
    }
}
extension SSGC.ModuleGraph
{
    /// Returns all dependencies of the given module (including transitive dependencies),
    /// sorted in topological dependency order. The list begins with all the standard library
    /// modules and ends with the given module.
    func constituents(of module:__owned SSGC.ModuleLayout) throws -> [SSGC.ModuleLayout]
    {
        var dependencies:[Vertex] = module.dependencies.modules.map
        {
            .init(module: self.sinkLayout.cultures[$0], in: self.sink.id)
        }
        for dependency:Symbol.Product in module.dependencies.products
        {
            guard
            let modules:[SSGC.ModuleLayout] = self.productPartitions[dependency]
            else
            {
                throw TargetNode.DependencyError.undefinedProduct(dependency)
            }

            for module:SSGC.ModuleLayout in modules
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

        var modules:[SSGC.ModuleLayout] = self.standardLibrary
        for dependency:Vertex in dependencies
        {
            modules.append(dependency.layout)
        }
        modules.append(module)
        return modules
    }

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
