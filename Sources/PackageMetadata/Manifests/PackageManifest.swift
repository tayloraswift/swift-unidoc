import JSONDecoding
import PackageGraphs
import SemanticVersions

public
struct PackageManifest:Equatable, Sendable
{
    /// The name of the package. This is *not* always the same as the package’s
    /// identity, but often is.
    public
    let name:String
    public
    let root:Repository.Root
    public
    let requirements:[PlatformRequirement]
    public
    let dependencies:[Repository.Dependency]
    public
    let products:[Product]
    public
    let targets:[Target]
    /// The `swift-tools-version` format of this manifest.
    public
    let format:SemanticVersion

    @inlinable public
    init(name:String,
        root:Repository.Root,
        requirements:[PlatformRequirement] = [],
        dependencies:[Repository.Dependency] = [],
        products:[Product] = [],
        targets:[Target] = [],
        format:SemanticVersion)
    {
        self.name = name
        self.root = root
        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products
        self.targets = targets
        self.format = format
    }
}
extension PackageManifest
{
    public
    func graph(platform:PlatformIdentifier,
        where predicate:(ProductType) throws -> Bool) throws ->
    (
        products:[ProductNode],
        targets:[TargetNode]
    )
    {
        let products:[Product] = try self.products.filter { try predicate($0.type) }
        let targets:Targets = try .init(indexing: self.targets)

        let targetOrdering:[Target] = try targets.included(by: products, on: platform)
        let targetNodes:[TargetNode] = try targetOrdering.map
        {
            let constituents:Set<String> = try targets.included(by: $0, on: platform)

            var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
            for (index, constituent):(Int, Target) in targetOrdering.enumerated()
                where constituents.contains(constituent.name)
            {
                dependencies.formUnion(constituent.dependencies.products(on: platform))
                //  don’t include the target’s own index
                if  constituent.name != $0.name
                {
                    modules.append(index)
                }
            }

            return .init(name: $0.name, type: $0.type, dependencies: .init(
                    products: dependencies.sorted(),
                    modules: modules),
                path: $0.path)
        }
        let productNodes:[ProductNode] = try products.map
        {
            let constituents:Set<String> = try targets.included(by: $0, on: platform)

            var (modules, dependencies):([Int], Set<ProductIdentifier>) = ([], [])
            for (index, constituent):(Int, Target) in targetOrdering.enumerated()
                where constituents.contains(constituent.name)
            {
                dependencies.formUnion(constituent.dependencies.products(on: platform))
                modules.append(index)
            }
            return .init(name: $0.name, type: $0.type, dependencies: .init(
                products: dependencies.sorted(),
                modules: modules))
        }

        return (productNodes, targetNodes)
    }

    static
    func order(topologically targets:[String: Target],
        consumers:inout [String: [Target]]) -> [Target]?
    {
        var sources:[Target] = []
        var dependencies:[String: Set<String>] = targets.compactMapValues
        {
            if $0.dependencies.targets.isEmpty
            {
                sources.append($0)
                return nil
            }
            else
            {
                return .init($0.dependencies.targets.lazy.map(\.id))
            }
        }

        //  Note: polarity reversed
        sources.sort { $1.name < $0.name }

        var ordered:[Target] = [] ; ordered.reserveCapacity(targets.count)

        while let source:Target = sources.popLast()
        {
            ordered.append(source)

            guard let next:[Target] = consumers.removeValue(forKey: source.name)
            else
            {
                continue
            }
            for next:Target in next
            {
                {
                    if  case _? = $0?.remove(source.name),
                        case true? = $0?.isEmpty
                    {
                        sources.append(next)
                        $0 = nil
                    }
                } (&dependencies[next.name])
            }
        }

        return dependencies.isEmpty && consumers.isEmpty ? ordered : nil
    }
}
extension PackageManifest
{
    public
    init(parsing json:String) throws
    {
        try self.init(json: try JSON.Object.init(parsing: json))
    }
}
extension PackageManifest:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case dependencies
        case name
        case products

        case root = "packageKind"
        enum Root:String
        {
            case root
        }

        case requirements = "platforms"
        case targets

        case format = "toolsVersion"
        enum Format:String
        {
            case version = "_version"
        }
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(
            name: try json[.name].decode(),
            root: try json[.root].decode(as: JSON.ObjectDecoder<CodingKeys.Root>.self)
            {
                try $0[.root].decode(
                    as: JSON.SingleElementRepresentation<Repository.Root>.self,
                    with: \.value)
            },
            requirements: try json[.requirements].decode(),
            dependencies: try json[.dependencies].decode(),
            products: try json[.products].decode(),
            targets: try json[.targets].decode(),
            format: try json[.format].decode(as: JSON.ObjectDecoder<CodingKeys.Format>.self)
            {
                try $0[.version].decode(as: JSON.StringRepresentation<SemanticVersion>.self,
                    with: \.value)
            })
    }
}
