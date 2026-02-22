import SystemIO
import UnidocRecords_LZ77

extension Unidoc.BuildArtifact {
    mutating func attach(log: FilePath, as type: Unidoc.BuildLogType) throws {
        do {
            let utf8: [UInt8] = try log.read()
            if  utf8.isEmpty {
                return
            }
            self.logs.append(
                .init(
                    text: .gzip(bytes: utf8[...], level: 10),
                    type: type
                )
            )
        } catch FileError.opening(_, .noSuchFileOrDirectory) {
        }
    }
}
