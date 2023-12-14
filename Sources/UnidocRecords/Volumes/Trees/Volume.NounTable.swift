import BSON

extension Volume
{
    /// A somewhat more-efficient representation for serializing an array of ``Row``s.
    @frozen @usableFromInline internal
    struct NounTable
    {
        @usableFromInline internal
        var rows:[Volume.Noun]

        @inlinable internal
        init(rows:[Volume.Noun])
        {
            self.rows = rows
        }
    }
}
extension Volume.NounTable
{
    @inlinable internal
    init?(eliding rows:[Volume.Noun])
    {
        if  rows.isEmpty
        {
            return nil
        }

        self.init(rows: rows)
    }
}
extension Volume.NounTable:BSONEncodable
{
    @usableFromInline internal
    func encode(to field:inout BSON.FieldEncoder)
    {
        var buffer:[UInt8] = []
        for row:Volume.Noun in self.rows
        {
            row.shoot.serialize(into: &buffer)

            switch row.style
            {
            case .stem(.culture):
                buffer.append(Discriminator.culture.rawValue)

            case .stem(.package):
                buffer.append(Discriminator.package.rawValue)

            case .stem(.foreign):
                buffer.append(Discriminator.foreign.rawValue)

            case .text(let text):
                buffer.append(Discriminator.custom.rawValue)
                buffer += text.utf8
                //  `0xFF` is a good choice for a terminator because it never appears in a
                //  valid UTF-8 sequence, and Swift strings never contain invalid UTF-8.
                buffer.append(0xFF)
            }
        }

        BSON.BinaryView<[UInt8]>.init(subtype: .generic, slice: buffer).encode(to: &field)
    }
}
extension Volume.NounTable:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable internal
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        self.init(rows: [])

        var i:Bytes.Index = bson.slice.startIndex
        var j:Bytes.Index = i
        while j < bson.slice.endIndex
        {
            var next:Bytes.Index = bson.slice.index(after: j)

            guard
            let discriminator:Discriminator = .init(rawValue: bson.slice[j])
            else
            {
                j = next
                continue
            }

            let shoot:Unidoc.Shoot = .deserialize(from: bson.slice[i ..< j])
            let style:Volume.Noun.Style

            switch discriminator
            {
            case .culture:
                style = .stem(.culture)

            case .package:
                style = .stem(.package)

            case .foreign:
                style = .stem(.foreign)

            case .custom:
                guard
                let terminator:Bytes.Index = bson.slice[next...].firstIndex(of: 0xFF)
                else
                {
                    throw Volume.NounTableMalformedError.unterminatedCustomText
                }

                style = .text(.init(decoding: bson.slice[next ..< terminator], as: UTF8.self))
                next = bson.slice.index(after: terminator)
            }

            self.rows.append(.init(shoot: shoot, style: style))

            i = next
            j = next
        }

        if  i != j
        {
            throw Volume.NounTableMalformedError.unterminatedRow
        }
    }
}
