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
extension Unidoc.NounTable:BSONBinaryEncodable
{
    @usableFromInline
    func encode(to bson:inout BSON.BinaryEncoder)
    {
        bson.subtype = Self.version

        for row:Unidoc.Noun in self.rows
        {
            bson += row.shoot

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
                bson.append(Discriminator.custom.rawValue)
                bson += text.utf8
                //  `0xFF` is a good choice for a terminator because it never appears in a
                //  valid UTF-8 sequence, and Swift strings never contain invalid UTF-8.
                bson.append(0xFF)
                continue
            }

            bson.append(trailer.0)
            withUnsafeBytes(of: (trailer.1 ?? -1).bigEndian) { bson += $0 }
        }
    }
}
extension Unidoc.NounTable:BSONBinaryDecodable
{
    @inlinable
    init(bson:BSON.BinaryDecoder) throws
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

        var i:Int = bson.bytes.startIndex
        var j:Int = i
        while j < bson.bytes.endIndex
        {
            let next:Int = bson.bytes.index(after: j)

            guard
            let discriminator:Discriminator = .init(rawValue: bson.bytes[j])
            else
            {
                j = next
                continue
            }

            let shoot:Unidoc.Shoot = .init(from: bson.bytes[i ..< j])
            let citizenship:Unidoc.Citizenship

            switch discriminator
            {
            case .culture:  citizenship = .culture
            case .package:  citizenship = .package
            case .foreign:  citizenship = .foreign
            case .custom:
                guard
                let terminator:Int = bson.bytes[next...].firstIndex(of: 0xFF)
                else
                {
                    throw Unidoc.NounTableMalformedError.unterminatedCustomText
                }

                let text:String = .init(decoding: bson.bytes[next ..< terminator],
                    as: UTF8.self)

                let k:Int = bson.bytes.index(after: terminator)

                self.rows.append(.init(shoot: shoot, type: .text(text)))

                i = k
                j = k

                continue
            }

            if  next < bson.bytes.endIndex,
                let k:Int = bson.bytes.index(next,
                    offsetBy: MemoryLayout<Int32>.size,
                    limitedBy: bson.bytes.endIndex)
            {
                let flags:Int32 = withUnsafeTemporaryAllocation(
                    byteCount: MemoryLayout<Int32>.size,
                    alignment: MemoryLayout<Int32>.alignment)
                {
                    $0.copyBytes(from: bson.bytes[next ..< k])
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

    @inlinable
    init(legacy bson:BSON.BinaryDecoder) throws
    {
        self.init(rows: [])

        var i:Int = bson.bytes.startIndex
        var j:Int = i
        while j < bson.bytes.endIndex
        {
            var next:Int = bson.bytes.index(after: j)

            guard
            let discriminator:Discriminator = .init(rawValue: bson.bytes[j])
            else
            {
                j = next
                continue
            }

            let shoot:Unidoc.Shoot = .init(from: bson.bytes[i ..< j])
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
                let terminator:Int = bson.bytes[next...].firstIndex(of: 0xFF)
                else
                {
                    throw Unidoc.NounTableMalformedError.unterminatedCustomText
                }

                type = .text(.init(decoding: bson.bytes[next ..< terminator], as: UTF8.self))
                next = bson.bytes.index(after: terminator)
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
