import SemanticVersions
import SymbolGraphs
import Symbols
import UnidocLinking
import UnidocRecords

extension Unidoc {
    /// A dynamic symbol graph linker.
    @frozen public struct DynamicLinker {
        @inlinable public init() {}
    }
}
extension Unidoc.DynamicLinker: Unidoc.GraphLinker {
    public func link(
        documentation: SymbolGraphObject<Unidoc.Edition>,
        dependencies: [SymbolGraphObject<Unidoc.Edition>],
        dependencyMetadata: [Unidoc.EditionMetadata?],
        latestRelease: Unidoc.Edition?,
        thisRelease: PatchVersion?,
        as volume: Symbol.Volume,
        in realm: Unidoc.Realm?
    ) -> Unidoc.Mesh {
        var context: Unidoc.LinkerContext = .init(linking: documentation, against: dependencies)
        let mesh: Unidoc.Mesh = context.link(
            pinnedDependencies: dependencyMetadata,
            latestRelease: latestRelease,
            thisRelease: thisRelease,
            as: volume,
            in: realm
        )

        context.status().emit(colors: .enabled)

        return mesh
    }
}
