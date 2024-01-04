import BSON
import Symbols
import UnidocAPI

extension Unidoc
{
    /// A somewhat more-efficient representation for serializing an array of ``Row``s.
    @frozen @usableFromInline internal
    struct NounTable
    {
        @usableFromInline internal
        var rows:[Unidoc.Noun]

        @inlinable internal
        init(rows:[Unidoc.Noun])
        {
            self.rows = rows
        }
    }
}
extension Unidoc.NounTable
{
    @inlinable internal
    init?(eliding rows:[Unidoc.Noun])
    {
        if  rows.isEmpty
        {
            return nil
        }

        self.init(rows: rows)
    }
}
extension Unidoc.NounTable
{
    @inlinable internal static
    var version:BSON.BinarySubtype { .custom(code: 0x80) }
}
extension Unidoc.NounTable:BSONEncodable
{
    @usableFromInline
    func encode(to field:inout BSON.FieldEncoder)
    {
        var buffer:[UInt8] = []
        for row:Unidoc.Noun in self.rows
        {
            row.shoot.serialize(into: &buffer)

            let trailer:(UInt8, Int32?)
            switch row.type
            {
            case .stem(.culture, let decl):
                trailer = (Discriminator.culture.rawValue, decl?.rawValue)

            case .stem(.package, let decl):
                trailer = (Discriminator.package.rawValue, decl?.rawValue)

            case .stem(.foreign, let decl):
                trailer = (Discriminator.foreign.rawValue, decl?.rawValue)

            case .text(let text):
                buffer.append(Discriminator.custom.rawValue)
                buffer += text.utf8
                //  `0xFF` is a good choice for a terminator because it never appears in a
                //  valid UTF-8 sequence, and Swift strings never contain invalid UTF-8.
                buffer.append(0xFF)
                continue
            }

            buffer.append(trailer.0)
            withUnsafeBytes(of: (trailer.1 ?? -1).bigEndian)
            {
                buffer += $0
            }
        }

        BSON.BinaryView<[UInt8]>.init(subtype: Self.version, slice: buffer).encode(to: &field)
    }
}
extension Unidoc.NounTable:BSONDecodable, BSONBinaryViewDecodable
{
    @inlinable internal
    init<Bytes>(bson:BSON.BinaryView<Bytes>) throws
    {
        if  case Self.version = bson.subtype
        {
            self.init(rows: [])
        }
        else
        {
            try self.init(legacy: bson)
            return
        }

        var i:Bytes.Index = bson.slice.startIndex
        var j:Bytes.Index = i
        while j < bson.slice.endIndex
        {
            let next:Bytes.Index = bson.slice.index(after: j)

            guard
            let discriminator:Discriminator = .init(rawValue: bson.slice[j])
            else
            {
                j = next
                continue
            }

            let shoot:Unidoc.Shoot = .deserialize(from: bson.slice[i ..< j])
            let citizenship:Unidoc.Citizenship

            switch discriminator
            {
            case .culture:  citizenship = .culture
            case .package:  citizenship = .package
            case .foreign:  citizenship = .foreign
            case .custom:
                guard
                let terminator:Bytes.Index = bson.slice[next...].firstIndex(of: 0xFF)
                else
                {
                    throw Unidoc.NounTableMalformedError.unterminatedCustomText
                }

                let text:String = .init(decoding: bson.slice[next ..< terminator],
                    as: UTF8.self)

                let k:Bytes.Index = bson.slice.index(after: terminator)

                self.rows.append(.init(shoot: shoot, type: .text(text)))

                i = k
                j = k

                continue
            }

            if  next < bson.slice.endIndex,
                let k:Bytes.Index = bson.slice.index(next,
                    offsetBy: MemoryLayout<Int32>.size,
                    limitedBy: bson.slice.endIndex)
            {
                let flags:Int32 = withUnsafeTemporaryAllocation(
                    byteCount: MemoryLayout<Int32>.size,
                    alignment: MemoryLayout<Int32>.alignment)
                {
                    $0.copyBytes(from: bson.slice[next ..< k])
                    return .init(bigEndian: $0.load(as: Int32.self))
                }

                let decl:Phylum.DeclFlags? = .init(rawValue: flags)

                self.rows.append(.init(shoot: shoot, type: .stem(citizenship, decl)))

                i = k
                j = k
            }
            else
            {
                throw Unidoc.NounTableMalformedError.missingTrailer
            }
        }

        if  i != j
        {
            throw Unidoc.NounTableMalformedError.unterminatedRow
        }
    }

    @inlinable internal
    init<Bytes>(legacy bson:BSON.BinaryView<Bytes>) throws
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
            let type:Unidoc.NounType

            switch discriminator
            {
            case .culture:
                type = .stem(.culture, nil)

            case .package:
                type = .stem(.package, nil)

            case .foreign:
                type = .stem(.foreign, nil)

            case .custom:
                guard
                let terminator:Bytes.Index = bson.slice[next...].firstIndex(of: 0xFF)
                else
                {
                    throw Unidoc.NounTableMalformedError.unterminatedCustomText
                }

                type = .text(.init(decoding: bson.slice[next ..< terminator], as: UTF8.self))
                next = bson.slice.index(after: terminator)
            }

            self.rows.append(.init(shoot: shoot, type: type))

            i = next
            j = next
        }

        if  i != j
        {
            throw Unidoc.NounTableMalformedError.unterminatedRow
        }
    }
}
