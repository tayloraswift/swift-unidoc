import Signatures

extension Signature.Expanded
{
    @frozen public
    struct InterestingKeywords
    {
        public
        var actor:Bool
        public
        var `class`:Bool

        @inlinable public
        init(actor:Bool = false, `class`:Bool = false)
        {
            self.actor = actor
            self.class = `class`
        }
    }
}
