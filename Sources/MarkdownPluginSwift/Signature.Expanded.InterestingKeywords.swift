import Signatures

extension Signature.Expanded
{
    @frozen public
    struct InterestingKeywords
    {
        public
        var actor:Bool
        public
        var attached:Bool
        public
        var `class`:Bool
        public
        var freestanding:Bool

        @inlinable public
        init(actor:Bool = false,
            attached:Bool = false,
            `class`:Bool = false,
            freestanding:Bool = false)
        {
            self.actor = actor
            self.attached = attached
            self.class = `class`
            self.freestanding = freestanding
        }
    }
}
