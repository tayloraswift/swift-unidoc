import UCF

extension UCF.PatternFilter.Identifier:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral:String)
    {
        self.init(stringLiteral)!
    }
}
