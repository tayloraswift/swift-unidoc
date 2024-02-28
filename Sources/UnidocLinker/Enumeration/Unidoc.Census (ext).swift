import UnidocRecords

extension Unidoc.Census
{
    init(from enumerator:Enumerator)
    {
        self.init(
            interfaces: .init(ordered: enumerator.interfaces.sorted { $0.key < $1.key} ),
            unweighted: .init(coverage: enumerator.coverage,
                decls: enumerator.phyla),
            weighted: .init(coverage: [:],
                decls: enumerator.phyla + enumerator.phylaInherited))
    }
}
