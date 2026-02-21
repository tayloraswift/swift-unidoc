extension SSGC {
    @_spi(testable) public struct Resource {
        private let file: any ResourceFile
        let id: Int32

        @_spi(testable) public init(file: any ResourceFile, id: Int32) {
            self.file = file
            self.id = id
        }
    }
}
extension SSGC.Resource {
    func text(trimmingTrailingNewlines: Bool = true) throws -> SSGC.ResourceText {
        .init(
            utf8: try self.file.read(as: [UInt8].self),
            trimmingTrailingNewlines: trimmingTrailingNewlines
        )
    }
}
