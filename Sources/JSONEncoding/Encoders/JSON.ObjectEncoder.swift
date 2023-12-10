import JSONAST

extension JSON
{
    @frozen public
    struct ObjectEncoder<Key>:Sendable
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
extension JSON.ObjectEncoder:JSONEncoder
{
    @inlinable internal static
    func move(_ json:inout JSON) -> Self
    {
        json.utf8.append(0x7B) // '{'
        defer { json.utf8 = [] }
        return .init(json: json)
    }
    @inlinable internal mutating
    func move() -> JSON
    {
        self.first = true
        self.json.utf8.append(0x7D) // '}'
        defer { self.json.utf8 = [] }
        return  self.json
    }
}
extension JSON.ObjectEncoder
{
    @inlinable internal
    subscript(with key:String) -> JSON
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

            self.json += JSON.Literal<String>.init(key)
            self.json.utf8.append(0x3A) // ':'

            yield &self.json
        }
    }
}
extension JSON.ObjectEncoder<Any>
{
    @inlinable public
    subscript(key:String,
        yield:(inout JSON.ArrayEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: key][as: JSON.ArrayEncoder.self]) }
    }

    @inlinable public
    subscript<CodingKey>(key:String,
        _:CodingKey.Type = CodingKey.self,
        yield:(inout JSON.ObjectEncoder<CodingKey>) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: key][as: JSON.ObjectEncoder<CodingKey>.self]) }
    }

    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: key]) }
    }
}
extension JSON.ObjectEncoder where Key:RawRepresentable<String>
{
    @inlinable public
    subscript(key:Key,
        yield:(inout JSON.ArrayEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: key.rawValue][as: JSON.ArrayEncoder.self]) }
    }

    @inlinable public
    subscript<CodingKey>(key:Key,
        _:CodingKey.Type = CodingKey.self,
        yield:(inout JSON.ObjectEncoder<CodingKey>) -> ()) -> Void
    {
        mutating
        get { yield(&self[with: key.rawValue][as: JSON.ObjectEncoder<CodingKey>.self]) }
    }

    @inlinable public
    subscript<Encodable>(key:Key) -> Encodable? where Encodable:JSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self[with: key.rawValue]) }
    }
}
