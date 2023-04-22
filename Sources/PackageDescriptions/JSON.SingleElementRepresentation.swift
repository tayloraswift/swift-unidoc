import JSONDecoding
import JSONEncoding

extension JSON
{
    /// Decodes or encodes a type that normally uses a different coding scheme
    /// by boxing it in a single-element array. This is here and not in the
    /// main JSON library, because only SwiftPM uses these demented schema.
    struct SingleElementRepresentation<Value>
    {
        let value:Value

        init(_ value:Value)
        {
            self.value = value
        }
    }
}
extension JSON.SingleElementRepresentation:JSONDecodable where Value:JSONDecodable
{
    init(json:JSON) throws
    {
        let json:JSON.Array = try .init(json: json)
        try json.shape.expect(count: 1)
        self.init(try json[0].decode())
    }
}
extension JSON.SingleElementRepresentation:JSONEncodable where Value:JSONEncodable
{
    func encoded(as _:JSON.Type) -> JSON
    {
        [self.value.encoded(as: JSON.self)]
    }
}
