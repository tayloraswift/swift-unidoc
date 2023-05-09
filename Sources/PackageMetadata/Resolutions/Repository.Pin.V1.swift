import JSONDecoding
import Repositories

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
        let state:Repository.Pin.State = try json[.state].decode()
        let location:String = try json[.location].decode()
        self.init(value: .init(id: try json[.id].decode(),
            reference: state.reference,
            revision: state.revision,
            location: location.first == "/" ?
                .local(root: .init(location)) :
                .remote(url: location)))
    }
}
