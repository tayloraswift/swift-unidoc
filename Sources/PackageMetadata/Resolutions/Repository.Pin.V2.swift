import JSONDecoding
import ModuleGraphs

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
    enum CodingKey:String, Sendable
    {
        case id = "identity"
        case location
        case state
        case type = "kind"
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let location:Repository
        switch try json[.type].decode(to: DependencyType.self)
        {
        case .localSourceControl:
            location = .local(root: try json[.location].decode())

        case .remoteSourceControl:
            location = .remote(url: try json[.location].decode())
        }

        self.init(value: .init(id: try json[.id].decode(),
            location: location,
            state: try json[.state].decode()))
    }
}
