import SymbolGraphs

extension Unidoc
{
    enum SemanticPriority:Equatable, Comparable
    {
        case available  (Phylum, String, Int32)
        case removed    (Phylum, String, Int32)
    }
}
extension Unidoc.SemanticPriority:Unidoc.SortPriority
{
    static
    func of(decl:SymbolGraph.Decl, at index:Int32) -> Self?
    {
        let phylum:Phylum = .init(decl.phylum, position: decl.location?.position)

        return decl.signature.availability.isGenerallyRecommended
            ? .available(phylum, decl.path.last, index)
            : .removed(phylum, decl.path.last, index)
    }
}
