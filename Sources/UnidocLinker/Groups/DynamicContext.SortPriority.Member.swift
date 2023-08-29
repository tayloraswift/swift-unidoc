extension DynamicContext.SortPriority
{
    enum Member:Equatable, Comparable
    {
        case `var`
        case `subscript`
        case `operator`
        case `func`
    }
}
