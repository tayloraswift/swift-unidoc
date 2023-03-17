import JSONDecoding

extension PackageDependency
{
    @frozen public
    struct Resolvable:Equatable, Sendable
    {
        public
        let id:PackageIdentifier
        public
        let requirement:PackageRequirement
        public
        let location:PackageRepository

        @inlinable public
        init(id:PackageIdentifier, requirement:PackageRequirement, location:PackageRepository)
        {
            self.id = id
            self.requirement = requirement
            self.location = location
        }
    }
}
extension PackageDependency.Resolvable:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "identity"

        case location
        enum Location:String
        {
            case local
            case remote
        }

        case requirement
        enum Requirement:String
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
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        self.init(id: try json[.id].decode(),
            requirement: try json[.requirement].decode(using: CodingKeys.Requirement.self)
            {
                let json:JSON.ExplicitField<CodingKeys.Requirement> = try $0.single()
                switch json.key
                {
                case .branch:
                    return .reference(.branch(try json.decode(
                        as: JSON.SingleElementRepresentation<String>.self,
                        with: \.value)))
                
                case .exact:
                    return .reference(.version(try json.decode(
                        as: JSON.SingleElementRepresentation<
                            JSON.StringRepresentation<SemanticVersion>>.self,
                        with: \.value.value)))
                
                case .range:
                    return .range(try json.decode(
                        as: JSON.SingleElementRepresentation<
                            JSON.ObjectDecoder<CodingKeys.Requirement.Range>>.self)
                    {
                        try $0.value[.lowerBound].decode(
                            as: JSON.StringRepresentation<SemanticVersion>.self,
                            with: \.value)
                        ..< $0.value[.upperBound].decode(
                            as: JSON.StringRepresentation<SemanticVersion>.self,
                            with: \.value)
                    })
                
                case .revision:
                    return .revision(try json.decode(
                        as: JSON.SingleElementRepresentation<GitRevision>.self,
                        with: \.value))
                }
            },
            location: try json[.location].decode(using: CodingKeys.Location.self)
            {
                let json:JSON.ExplicitField<CodingKeys.Location> = try $0.single()
                switch json.key
                {
                case .local:
                    return .local(file: try json.decode(
                        as: JSON.SingleElementRepresentation<PackageRoot>.self,
                        with: \.value))
                
                case .remote:
                    return .remote(url: try json.decode(
                        as: JSON.SingleElementRepresentation<String>.self,
                        with: \.value))
                }
            })
    }
}
