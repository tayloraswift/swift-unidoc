import JSONDecoding
import ModuleGraphs

extension Repository.Pin
{
    struct V1
    {
        let value:Repository.Pin

        private
        init(value:Repository.Pin)
        {
            self.value = value
        }
    }
}

extension Repository.Pin.V1:JSONObjectDecodable
{
    public
    enum CodingKeys:String
    {
        case id = "package"
        case location = "repositoryURL"
        case state
    }
    public
    init(json:JSON.ObjectDecoder<CodingKeys>) throws
    {
        let location:String = try json[.location].decode()
        self.init(value: .init(id: try json[.id].decode(),
            location: location.first == "/" ?
                .local(root: .init(location)) :
                .remote(url: location),
            state: try json[.state].decode()))
    }
}
