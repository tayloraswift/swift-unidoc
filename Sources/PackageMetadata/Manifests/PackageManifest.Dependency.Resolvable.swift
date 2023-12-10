import JSON
import PackageGraphs
import SemanticVersions
import SHA1
import Symbols

extension PackageManifest.Dependency
{
    @frozen public
    struct Resolvable:Equatable, Sendable
    {
        public
        let id:Symbol.Package
        public
        let requirement:PackageManifest.DependencyRequirement
        public
        let location:PackageManifest.DependencyLocation

        @inlinable public
        init(id:Symbol.Package,
            requirement:PackageManifest.DependencyRequirement,
            location:PackageManifest.DependencyLocation)
        {
            self.id = id
            self.requirement = requirement
            self.location = location
        }
    }
}
extension PackageManifest.Dependency.Resolvable:JSONObjectDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case id = "identity"

        case location
        enum Location:String, Sendable
        {
            case local
            case remote
            enum Remote:String
            {
                //  appears when dumping tools version 5.1 manifest with 5.9 toolchain
                case urlString
            }
        }

        case requirement
        enum Requirement:String, Sendable
        {
            case branch
            case exact

            case range
            enum Range:String
            {
                case lowerBound
                case upperBound
            }

            case revision
        }
    }

    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        self.init(id: try json[.id].decode(),
            requirement: try json[.requirement].decode(using: CodingKey.Requirement.self)
            {
                let json:JSON.FieldDecoder<CodingKey.Requirement> = try $0.single()
                switch json.key
                {
                case .branch:
                    return .refname(try json.decode(
                        as: JSON.SingleElementRepresentation<String>.self,
                        with: \.value))

                case .exact:
                    return .stable(.exact(try json.decode(
                        as: JSON.SingleElementRepresentation<
                            JSON.StringRepresentation<PatchVersion>>.self,
                        with: \.value.value)))

                case .range:
                    return .stable(.range(try json.decode(
                        as: JSON.SingleElementRepresentation<
                            JSON.ObjectDecoder<CodingKey.Requirement.Range>>.self)
                    {
                        try $0.value[.lowerBound].decode(
                            as: JSON.StringRepresentation<PatchVersion>.self,
                            with: \.value)
                        ..< $0.value[.upperBound].decode(
                            as: JSON.StringRepresentation<PatchVersion>.self,
                            with: \.value)
                    }))

                case .revision:
                    return .revision(try json.decode(
                        as: JSON.SingleElementRepresentation<SHA1>.self,
                        with: \.value))
                }
            },
            location: try json[.location].decode(using: CodingKey.Location.self)
            {
                let json:JSON.FieldDecoder<CodingKey.Location> = try $0.single()
                switch json.key
                {
                case .local:
                    return .local(root: try json.decode(
                        as: JSON.SingleElementRepresentation<Symbol.FileBase>.self,
                        with: \.value))

                case .remote:
                    let json:JSON.Array = try .init(json: json.value)
                    try json.shape.expect(count: 1)

                    let url:String
                    do
                    {
                        url = try json[0].decode()
                    }
                    catch
                    {
                        url = try json[0].decode(using: CodingKey.Location.Remote.self)
                        {
                            try $0[.urlString].decode()
                        }
                    }
                    return .remote(url: url)
                }
            })
    }
}
