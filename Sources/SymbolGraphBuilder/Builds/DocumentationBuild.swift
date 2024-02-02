import SymbolGraphs

protocol DocumentationBuild
{
    mutating
    func compile(with swift:Toolchain,
        pretty:Bool) async throws -> (SymbolGraphMetadata, SPM.Artifacts)
}
