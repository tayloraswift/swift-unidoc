import JSON

extension JSON {
    /// Decodes or encodes a type that normally uses a different coding scheme
    /// by boxing it in a single-element array. This is here and not in the
    /// main JSON library, because only SwiftPM uses these demented schema.
    struct SingleElementRepresentation<Value> {
        let value: Value

        init(_ value: Value) {
            self.value = value
        }
    }
}
extension JSON.SingleElementRepresentation: JSONDecodable where Value: JSONDecodable {
    init(json: JSON.Node) throws {
        let json: JSON.Array = try .init(json: json)
        try json.shape.expect(count: 1)
        self.init(try json[0].decode())
    }
}
