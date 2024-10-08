import BSON
import LZ77
import SymbolGraphs

extension Unidoc.BuildPayload
{
    init(metadata:SymbolGraphMetadata, graph:borrowing SymbolGraph, level:Int = 12)
    {
        let document:BSON.Document = .init(encoding: graph)
        let size:Int64 = .init(document.bytes.count)

        print("Compressing symbol graph (\(size / 1_000) KB)...")

        var deflator:LZ77.Deflator

        deflator = .init(format: .zlib, level: level, hint: 128 << 10)
        deflator.push(document.bytes, last: true)

        var bytes:[UInt8] = []

        while let part:[UInt8] = deflator.pull()
        {
            bytes += part
        }

        print("Compressed symbol graph (\(bytes.count / 1_000) KB)")

        self.init(metadata: metadata, zlib: bytes[...], size: size)
    }
}
