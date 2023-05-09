import JSONDecoding
import Repositories

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

    @inlinable public
    init(name:String,
        root:Repository.Root,
        requirements:[PlatformRequirement] = [],
        dependencies:[Repository.Dependency] = [],
        products:[Product] = [],
        targets:[Target] = [])
    {
        self.name = name
        self.root = root
        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products
        self.targets = targets
    }
}

extension PackageManifest
{
    /// Returns all targets in the manifest that are included, directly or indirectly,
    /// by at least one library product.
    public
    func libraries() throws -> [Target]
    {
        let targets:[TargetIdentifier: Target] = try .init(
            self.targets.lazy.map { ($0.id, $0) })
        {
            throw TargetError.duplicate($1.id)
        }

        func target(_ id:TargetIdentifier) throws -> Target
        {
            if  let target:Target = targets[id]
            {
                return target
            }
            else
            {
                throw TargetError.undefined(id)
            }
        }

        var explorable:[[TargetDependency]] = []
        var explored:Set<TargetIdentifier> = []
        for product:Product in self.products
        {
            guard case .library = product.type
            else
            {
                continue
            }
            for id:TargetIdentifier in product.targets
            {
                if  case nil = explored.update(with: id)
                {
                    explorable.append(try target(id).dependencies)
                }
            }
        }
        while let dependencies:[TargetDependency] = explorable.popLast()
        {
            for dependency:TargetDependency in dependencies
            {
                if  case .target(let dependency) = dependency,
                    case nil = explored.update(with: dependency.id)
                {
                    explorable.append(try target(dependency.id).dependencies)
                }
            }
        }
        return self.targets.filter { explored.contains($0.id) }
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
            targets: try json[.targets].decode())
    }
}
