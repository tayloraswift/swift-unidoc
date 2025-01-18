import Signatures

extension SignatureLandmarks
{
    @frozen public
    struct InterestingKeywords
    {
        public
        var actor:Bool
        public
        var async:Bool
        public
        var attached:Bool
        public
        var `class`:Bool
        public
        var final:Bool
        public
        var freestanding:Bool

        @inlinable
        init(
            actor:Bool = false,
            async:Bool = false,
            attached:Bool = false,
            `class`:Bool = false,
            final:Bool = false,
            freestanding:Bool = false)
        {
            self.actor = actor
            self.async = async
            self.attached = attached
            self.class = `class`
            self.final = final
            self.freestanding = freestanding
        }
    }
}
