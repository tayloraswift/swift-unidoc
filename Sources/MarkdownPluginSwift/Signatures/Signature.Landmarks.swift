import Signatures

extension Signature
{
    @frozen public
    struct Landmarks
    {
        public
        var keywords:InterestingKeywords

        @inlinable public
        init()
        {
            self.keywords = .init()
        }
    }
}
