import BSON
import LZ77
import S3

extension Unidoc.Snapshot
{
    mutating
    func moveSymbolGraph(to s3:AWS.S3.Client) async throws
    {
        var deflator:LZ77.Deflator

        if  let bson:ArraySlice<UInt8> = self.move()
        {
            deflator = .init(format: .zlib, level: 7, hint: 128 << 10)
            deflator.push(bson, last: true)
        }
        else
        {
            return
        }

        var bson:[UInt8] = []

        while let part:[UInt8] = deflator.pull()
        {
            bson += part
        }

        self.type = .bson_zz

        try await s3.connect
        {
            try await $0.put(
                content: .init(body: .binary(bson), type: .application(.bson)),
                using: .standard,
                path: "\(self.path)")
        }
    }
}
