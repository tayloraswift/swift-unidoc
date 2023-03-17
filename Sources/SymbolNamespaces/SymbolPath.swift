import JSONDecoding
import JSONEncoding

extension SymbolPath:JSONDecodable, JSONEncodable
{
    public
    init(json:JSON) throws
    {
        let json:JSON.Array = try .init(json: json)
        try json.shape.expect { $0 > 0 }

        let last:Int = json.index(before: json.endIndex)
        self.init(
            prefix: try json[..<last].map { try $0.decode() },
            last: try json[last].decode())
    }
}
