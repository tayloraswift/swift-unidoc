import JSONAST

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
    subscript(with _:(Index) -> Void) -> JSON
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
        yield:(inout Self) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: +][as: Self.self]) }
    }

    @inlinable public
    subscript<CodingKey>(_:(Index) -> Void,
        _:CodingKey.Type = CodingKey.self,
        yield:(inout JSON.ObjectEncoder<CodingKey>) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: +][as: JSON.ObjectEncoder<CodingKey>.self]) }
    }

    @inlinable public
    subscript<Encodable>(_:(Index) -> Void) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: +]) }
    }
}
