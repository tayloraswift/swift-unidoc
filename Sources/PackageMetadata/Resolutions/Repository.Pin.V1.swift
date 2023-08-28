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
        let location:String = try json[.location].decode()
        let start:String.Index = location.lastIndex(of: "/").map(location.index(after:)) ??
            location.startIndex

        self.init(value: .init(id: .init(location[start...].prefix(while: { $0 != "." })),
            location: location.first == "/" ?
                .local(root: .init(location)) :
                .remote(url: location),
            state: try json[.state].decode()))
    }
}
