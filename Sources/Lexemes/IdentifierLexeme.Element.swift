extension IdentifierLexeme
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
extension IdentifierLexeme.Element
{
    @inlinable public
    init(_ first:IdentifierLexeme.First)
    {
        self.codepoint = first.codepoint
    }
    @inlinable public
    init?(_ codepoint:Unicode.Scalar)
    {
        switch codepoint 
        {
        case    "0" ... "9", 
                "\u{0300}" ... "\u{036F}", 
                "\u{1DC0}" ... "\u{1DFF}", 
                "\u{20D0}" ... "\u{20FF}", 
                "\u{FE20}" ... "\u{FE2F}":
            self.init(codepoint: codepoint)
        
        default:
            guard let first:IdentifierLexeme.First = .init(codepoint)
            else
            {
                return nil
            }

            self.init(first)
        }
    }
}
