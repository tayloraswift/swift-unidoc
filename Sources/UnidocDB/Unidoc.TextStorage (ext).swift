import LZ77
import UnidocRecords

extension Unidoc.TextStorage
{
    public
    init(compressing utf8:__shared ArraySlice<UInt8>)
    {
        self = .gzip(Gzip.archive(bytes: utf8, level: 7, hint: 128 << 10)[...])
    }

    public consuming
    func utf8() throws -> ArraySlice<UInt8>
    {
        switch self
        {
        case .utf8(let utf8):   utf8
        case .gzip(let gzip):   try Gzip.extract(from: gzip)[...]
        }
    }
}
