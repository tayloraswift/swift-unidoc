import Sources

extension DynamicContext.SortPriority
{
    enum Constructor:Equatable, Comparable
    {
        /// Enumeration cases sort by their declaration order. Because it is impossible for
        /// them to appear in a different file than the enum’s declaration, we can simply use
        /// the source position of the case declaration.
        case `case`(SourcePosition)
        case  initializer
        case `var`
        case `subscript`
        case `func`
    }
}
