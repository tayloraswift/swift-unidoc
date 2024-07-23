import JSON
import OrderedCollections
import PackageGraphs
import SemanticVersions
import SymbolGraphs
import Symbols

extension SPM
{
    /// Manifest ur destiny ✨
    @frozen public
    struct Manifest:Equatable, Sendable
    {
        /// The name of the package. This is *not* always the same as the package’s
        /// identity, but often is. Some packages use this field to store a “marketing
        /// name” for the package, such as `Swift Argument Parser`.
        public
        let name:String
        public
        var root:Symbol.FileBase
        public
        var requirements:[SymbolGraphMetadata.PlatformRequirement]
        public
        var dependencies:[Dependency]
        public
        var products:OrderedDictionary<String, Product>
        public
        var targets:OrderedDictionary<String, TargetNode>
        /// The `swift-tools-version` format of this manifest.
        public
        var format:PatchVersion

        @inlinable
        init(name:String,
            root:Symbol.FileBase,
            requirements:[SymbolGraphMetadata.PlatformRequirement] = [],
            dependencies:[Dependency] = [],
            products:OrderedDictionary<String, Product>,
            targets:OrderedDictionary<String, TargetNode>,
            format:PatchVersion)
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
}
extension SPM.Manifest
{
    @inlinable public
    init(name:String,
        root:Symbol.FileBase,
        requirements:[SymbolGraphMetadata.PlatformRequirement] = [],
        dependencies:[Dependency] = [],
        products:[Product] = [],
        targets:[TargetNode] = [],
        format:PatchVersion)
    {
        self.name = name
        self.root = root
        self.requirements = requirements
        self.dependencies = dependencies
        self.products = products.reduce(into: [:]) { $0[$1.name] = $1 }
        self.targets = targets.reduce(into: [:]) { $0[$1.name] = $1 }
        self.format = format
    }
}
extension SPM.Manifest
{
    /// The name of the snippets directory. This is supposed to be configurable, but due to
    /// sheer incompetence, it is currently always the string `Snippets`.
    @inlinable public
    var snippets:String? { nil }

    public mutating
    func normalizeUnqualifiedDependencies(
        with packageContainingProduct:[String: Symbol.Package]) throws
    {
        let targets:OrderedSet<String> = self.targets.keys
        for i:Int in self.targets.values.indices
        {
            try
            {
                for nominal:TargetNode.Dependency<String> in $0.nominal
                {
                    if  targets.contains(nominal.id)
                    {
                        $0.targets.append(.init(id: nominal.id, platforms: nominal.platforms))
                    }
                    else if
                        let package:Symbol.Package = packageContainingProduct[nominal.id]
                    {
                        let id:Symbol.Product = .init(name: nominal.id, package: package)
                        $0.products.append(.init(id: id, platforms: nominal.platforms))
                    }
                    else
                    {
                        throw TargetNode.DependencyError.undefinedNominal(nominal.id)
                    }
                }

                $0.nominal = []

            } (&self.targets.values[i].dependencies)
        }
    }
}
extension SPM.Manifest:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case dependencies
        case name
        case products

        case root = "packageKind"
        enum Root:String, Sendable
        {
            case root
        }

        case requirements = "platforms"
        /// Sadly, we cannot conform ``PlatformRequirement`` itself to JSONObjectDecodable,
        /// because its `CodingKey` witness would conflict with its BSONDocumentDecodable
        /// type witness.
        enum Requirements:String, Sendable
        {
            case id = "platformName"
            case min = "version"
        }

        case targets

        case format = "toolsVersion"
        enum Format:String, Sendable
        {
            case version = "_version"
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(
            name: try json[.name].decode(),
            root: try json[.root].decode(as: JSON.ObjectDecoder<CodingKey.Root>.self)
            {
                try $0[.root].decode(
                    as: JSON.SingleElementRepresentation<Symbol.FileBase>.self,
                    with: \.value)
            },
            requirements: try json[.requirements].decode(as: JSON.Array.self)
            {
                try $0.map
                {
                    try $0.decode(using: CodingKey.Requirements.self)
                    {
                        .init(id: try $0[.id].decode(),
                            min: try $0[.min].decode(
                                as: JSON.StringRepresentation<NumericVersion>.self,
                                with: \.value))
                    }
                }
            },
            dependencies: try json[.dependencies].decode(),
            products: try json[.products].decode(),
            targets: try json[.targets].decode(),
            format: try json[.format].decode(as: JSON.ObjectDecoder<CodingKey.Format>.self)
            {
                try $0[.version].decode(as: JSON.StringRepresentation<PatchVersion>.self,
                    with: \.value)
            })
    }
}
