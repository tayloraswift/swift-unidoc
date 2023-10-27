import JSONDecoding
import ModuleGraphs
import PackageGraphs
import SemanticVersions

extension PackageNode.Dependency.Resolvable:JSONObjectDecodable
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
                let json:JSON.ExplicitField<CodingKey.Requirement> = try $0.single()
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
                        as: JSON.SingleElementRepresentation<Repository.Revision>.self,
                        with: \.value))
                }
            },
            location: try json[.location].decode(using: CodingKey.Location.self)
            {
                let json:JSON.ExplicitField<CodingKey.Location> = try $0.single()
                switch json.key
                {
                case .local:
                    return .local(root: try json.decode(
                        as: JSON.SingleElementRepresentation<Repository.Root>.self,
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
