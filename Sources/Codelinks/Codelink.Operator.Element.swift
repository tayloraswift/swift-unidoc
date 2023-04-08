extension Codelink.Operator
{
    @frozen public
    struct Element:Equatable, Hashable, Sendable
    {
        public
        let codepoint:Unicode.Scalar

        @inlinable internal
        init(codepoint:Unicode.Scalar)
        {
            self.codepoint = codepoint
        }
    }
}
extension Codelink.Operator.Element
{
    @inlinable public
    init(_ first:Codelink.Operator.Head)
    {
        self.codepoint = first.codepoint
    }
    @inlinable public
    init?(_ codepoint:Unicode.Scalar)
    {
        switch codepoint 
        {
        case    "\u{0300}" ... "\u{036F}",
                "\u{1DC0}" ... "\u{1DFF}",
                "\u{20D0}" ... "\u{20FF}",
                "\u{FE00}" ... "\u{FE0F}",
                "\u{FE20}" ... "\u{FE2F}",
                "\u{E0100}" ... "\u{E01EF}":
            self.init(codepoint: codepoint)
        
        default:
            guard let first:Codelink.Operator.Head = .init(codepoint)
            else
            {
                return nil
            }
            //  Note: if an operator does not start with a dot,
            //  it can’t contain one elsewhere
            self.init(first)
        }
    }
}
