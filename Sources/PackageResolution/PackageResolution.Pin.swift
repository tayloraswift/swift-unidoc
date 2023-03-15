import JSONDecoding
import SemanticVersions

extension PackageResolution
{
    @frozen public 
    struct Pin:Identifiable, Equatable, Sendable 
    {
        public 
        let id:PackageIdentifier
        public
        let requirement:PackageRequirement
        public 
        let revision:String
        public 
        let location:String?

        @inlinable public 
        init(id:PackageIdentifier,
            requirement:PackageRequirement,
            revision:String,
            location:String? = nil)
        {
            self.id = id 
            self.requirement = requirement
            self.revision = revision 
            self.location = location 
        }
    }
}
extension PackageResolution.Pin:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "identity"
        case location

        case state
        enum State:String
        {
            case branch
            case revision
            case version
        }

        case type = "kind"
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws 
    {
        let _:PackageResolution.DependencyType = try json[.type].decode()
        let state:State = try json[.state].decode()
        self.init(id: try json[.id].decode(),
            requirement: state.requirement,
            revision: state.revision,
            location: try json[.location]?.decode())
    }
}
