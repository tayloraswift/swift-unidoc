import JSONDecoding
import Repositories

extension Repository.Pin
{
    struct V2
    {
        let value:Repository.Pin

        private
        init(value:Repository.Pin)
        {
            self.value = value
        }
    }
}

extension Repository.Pin.V2:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "identity"
        case location
        case state
        case type = "kind"
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let state:Repository.Pin.State = try json[.state].decode()

        let location:Repository
        switch try json[.type].decode(to: DependencyType.self)
        {
        case .localSourceControl:
            location = .local(root: try json[.location].decode())

        case .remoteSourceControl:
            location = .remote(url: try json[.location].decode())
        }

        self.init(value: .init(id: try json[.id].decode(),
            reference: state.reference,
            revision: state.revision,
            location: location))
    }
}
