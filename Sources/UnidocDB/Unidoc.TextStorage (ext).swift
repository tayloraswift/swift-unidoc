import LZ77
import UnidocRecords

extension Unidoc.TextStorage
{
    public
    init(compressing utf8:consuming ArraySlice<UInt8>)
    {
        var deflator:Gzip.Deflator = .init(level: 7, hint: 128 << 10)

        deflator.push(consume utf8, last: true)

        var gzip:[UInt8] = []
        while let part:[UInt8] = deflator.pull()
        {
            gzip += part
        }

        self = .gzip(gzip[...])
    }

    public consuming
    func utf8() throws -> ArraySlice<UInt8>
    {
        switch self
        {
        case .utf8(let utf8):
            return utf8

        case .gzip(let gzip):
            var inflator:Gzip.Inflator = .init()
            try inflator.push(consume gzip)
            return inflator.pull()[...]
        }
    }
}
