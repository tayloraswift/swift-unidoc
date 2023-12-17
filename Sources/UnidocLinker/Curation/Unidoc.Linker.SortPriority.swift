extension Unidoc.Linker
{
    enum SortPriority:Equatable, Comparable
    {
        case available  (Phylum, String, Int32)
        case removed    (Phylum, String, Int32)
    }
}
