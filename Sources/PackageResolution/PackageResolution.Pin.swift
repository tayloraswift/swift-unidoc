import JSONDecoding

extension PackageResolution
{
    @frozen public 
    struct Pin:Identifiable, Equatable, Sendable 
    {
        public 
        let id:PackageIdentifier
        public
        let reference:Repository.Reference
        public 
        let revision:Repository.Revision
        public
        let location:Repository

        @inlinable public 
        init(id:PackageIdentifier,
            reference:Repository.Reference,
            revision:Repository.Revision,
            location:Repository)
        {
            self.id = id 
            self.reference = reference
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
        let state:State = try json[.state].decode()

        let location:Repository
        switch try json[.type].decode(to: DependencyType.self)
        {
        case .localSourceControl:
            location = .local(root: try json[.location].decode())
        
        case .remoteSourceControl:
            location = .remote(url: try json[.location].decode())
        }

        self.init(id: try json[.id].decode(),
            reference: state.reference,
            revision: state.revision,
            location: location)
    }
}
