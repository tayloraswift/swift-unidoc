extension UCF
{
    @frozen public
    struct ConditionFilter:Equatable, Hashable, Sendable
    {
        public
        let keywords:Keywords
        public
        let expected:Bool

        @inlinable public
        init(keywords:Keywords, expected:Bool)
        {
            self.keywords = keywords
            self.expected = expected
        }
    }
}
