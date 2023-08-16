extension JSON
{
    @frozen public
    struct ArrayEncoder:Sendable
    {
        @usableFromInline internal
        var first:Bool
        @usableFromInline internal
        var json:JSON

        @inlinable internal
        init(json:JSON)
        {
            self.first = true
            self.json = json
        }
    }
}
extension JSON.ArrayEncoder:JSONEncoder
{
    @inlinable internal static
    func move(_ json:inout JSON) -> Self
    {
        json.utf8.append(0x5B) // '['
        defer { json.utf8 = [] }
        return .init(json: json)
    }
    @inlinable internal mutating
    func move() -> JSON
    {
        self.first = true
        self.json.utf8.append(0x5D) // ']'
        defer { self.json.utf8 = [] }
        return  self.json
    }
}
extension JSON.ArrayEncoder
{
    @inlinable internal
    subscript(_:(Index) -> Void) -> JSON
    {
        _read
        {
            yield .init(utf8: [])
        }
        _modify
        {
            if  self.first
            {
                self.first = false
            }
            else
            {
                self.json.utf8.append(0x2C) // ','
            }

            yield &self.json
        }
    }
}
extension JSON.ArrayEncoder
{
    @inlinable public
    subscript(_:(Index) -> Void,
        with encode:(inout Self) -> ()) -> Void
    {
        mutating
        get { encode(&self[+][as: Self.self]) }
    }

    @inlinable public
    subscript<CodingKey>(_:(Index) -> Void,
        _:CodingKey.Type = CodingKey.self,
        with encode:(inout JSON.ObjectEncoder<CodingKey>) -> ()) -> Void
    {
        mutating
        get { encode(&self[+][as: JSON.ObjectEncoder<CodingKey>.self]) }
    }

    @inlinable public
    subscript<Encodable>(_:(Index) -> Void) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[+]) }
    }
}
