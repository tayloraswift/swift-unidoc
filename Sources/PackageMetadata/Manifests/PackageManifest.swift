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
        let targets:Targets = try .init(indexing: self.targets)

        /// Targets that have been discovered, but not explored through.
        /// Targets that have been fully explored. Once ``explorable`` becomes
        /// empty again, this will contain every target that is included
        /// in at least one library product.
        var explored:[TargetIdentifier: Target] = [:]
        var queued:[Target] = []

        func explore(target id:TargetIdentifier) throws
        {
            try
            {
                if  case nil = $0
                {
                    let target:Target = try targets(id)
                    queued.append(target)
                    $0 = target
                }
            } (&explored[id])
        }

        for product:Product in self.products
        {
            guard case .library = product.type
            else
            {
                continue
            }
            for id:TargetIdentifier in product.targets
            {
                try explore(target: id)
            }
        }
        /// The list of targets that *directly* depend on each (explored) target.
        var consumers:[TargetIdentifier: [Target]] = [:]
        while let target:Target = queued.popLast()
        {
            // need to sort dependency set to make topological sort deterministic
            for id:TargetIdentifier in target.dependencies.targets.map(\.id).sorted()
            {
                consumers[id, default: []].append(target)
                try explore(target: id)
            }
        }

        if  let targets:[Target] = Self.order(topologically: explored, consumers: &consumers)
        {
            return targets
        }
        else
        {
            throw PackageManifestError.dependencyCycle
        }
    }

    private static
    func order(topologically targets:[TargetIdentifier: Target],
        consumers:inout [TargetIdentifier: [Target]]) -> [Target]?
    {
        var sources:[Target] = []
        var dependencies:[TargetIdentifier: Set<TargetIdentifier>] = targets.compactMapValues
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
        sources.sort { $1.id < $0.id }

        var ordered:[Target] = [] ; ordered.reserveCapacity(targets.count)

        while let source:Target = sources.popLast()
        {
            ordered.append(source)

            guard let next:[Target] = consumers.removeValue(forKey: source.id)
            else
            {
                continue
            }
            for next:Target in next
            {
                {
                    if  case _? = $0?.remove(source.id),
                        case true? = $0?.isEmpty
                    {
                        sources.append(next)
                        $0 = nil
                    }
                } (&dependencies[next.id])
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
