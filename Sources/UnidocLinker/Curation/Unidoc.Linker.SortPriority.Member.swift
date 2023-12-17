extension Unidoc.Linker.SortPriority
{
    enum Member:Equatable, Comparable
    {
        case `var`
        case `subscript`
        case `operator`
        case `func`
    }
}
