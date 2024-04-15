import System
import UnidocRecords_LZ77

extension Unidoc.BuildReport
{
    mutating
    func attach(log:FilePath, as type:Unidoc.BuildLogType) throws
    {
        let utf8:[UInt8] = try log.read()
        if  utf8.isEmpty
        {
            return
        }

        self.logs.append(.init(
            text: .gzip(bytes: utf8[...], level: 10),
            type: type))
    }
}
