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
    enum CodingKey:String
    {
        //  this field is completely useless!
        //  case id = "package"

        case location = "repositoryURL"
        case state
    }
    public
    init(json:JSON.ObjectDecoder<CodingKey>) throws
    {
        let repository:Repository = .init(location: try json[.location].decode())

        self.init(value: .init(id: .init(repository.name),
            location: repository,
            state: try json[.state].decode()))
    }
}
