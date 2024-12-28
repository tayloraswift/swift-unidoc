extension UCF
{
    enum TypeOperand
    {
        case bracket(TypePattern, TypePattern?)
        case closure([TypePattern], TypePattern)
        case nominal([(Range<String.Index>, [TypePattern])])
        /// A single parenthesized type, or nil if the type is a placeholder (`_`).
        case single(TypePattern?)
        /// A tuple containing either zero or two or more types.
        case tuple([TypePattern])
    }
}
