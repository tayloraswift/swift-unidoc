import SymbolGraphs
import SystemIO

extension SSGC {
    protocol DocumentationBuild {
        func compile(
            updating status: SSGC.StatusStream?,
            with swift: Toolchain,
            clean: Bool
        ) throws -> (SymbolGraphMetadata, any DocumentationSources)
    }
}
extension SSGC.DocumentationBuild {
    func build(
        toolchain swift: SSGC.Toolchain,
        define defines: [String] = [],
        status: SSGC.StatusStream? = nil,
        logger: SSGC.Logger = .default(),
        clean: Bool
    ) throws -> SymbolGraphObject<Void> {
        /// TODO: support values?
        let definitions: [String: Void] = defines.reduce(into: [:]) { $0[$1] = () }

        let metadata: SymbolGraphMetadata
        let package: any SSGC.DocumentationSources

        (metadata, package) = try self.compile(updating: status, with: swift, clean: clean)

        let documentation: SymbolGraph = try package.link(
            definitions: definitions,
            logger: logger,
            with: swift
        )

        return .init(metadata: metadata, graph: documentation)
    }
}
