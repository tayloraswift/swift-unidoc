import BSON
import FNV1
import UnidocAPI

extension Unidoc.Shoot {
    @inlinable public init<Bytes>(
        from bytes: borrowing Bytes
    ) where Bytes: RandomAccessCollection<UInt8> {
        let stem: Unidoc.Stem
        let hash: FNV24?
        if  let question: Bytes.Index = bytes.lastIndex(of: 0x00) {
            stem = .init(
                rawValue: .init(
                    decoding: (copy bytes)[..<question],
                    as: Unicode.UTF8.self
                )
            )

            hash = .init(
                String.init(
                    decoding: (copy bytes)[bytes.index(after: question)...],
                    as: Unicode.ASCII.self
                )
            )
        } else {
            stem = .init(rawValue: .init(decoding: (copy bytes), as: Unicode.UTF8.self))
            hash = nil
        }

        self.init(stem: stem, hash: hash)
    }

    @inlinable public static func += (bson: inout BSON.BinaryEncoder, self: Self) {
        bson += self.stem.rawValue.utf8
        if  let hash: FNV24 = self.hash {
            bson.append(0x00)
            bson += hash.description.utf8
        }
    }
}
