import SystemIO
import TraceableErrors

extension SSGC {
    public struct ManifestDumpError: Error {
        public let underlying: any Error
        public let root: FilePath.Directory
        public let leaf: Bool

        public init(underlying: any Error, root: FilePath.Directory, leaf: Bool) {
            self.underlying = underlying
            self.root = root
            self.leaf = leaf
        }
    }
}
extension SSGC.ManifestDumpError: TraceableError {
    public var notes: [String] {
        ["while dumping manifest for package at '\(self.root)'"]
    }
}
