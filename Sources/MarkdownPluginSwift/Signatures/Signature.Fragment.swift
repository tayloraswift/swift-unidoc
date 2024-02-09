import Signatures

extension Signature
{
    @frozen public
    struct Fragment:Equatable, Hashable
    {
        public
        let spelling:String
        public
        let referent:Scalar?

        @inlinable public
        init(_ spelling:String, referent:Scalar? = nil)
        {
            self.spelling = spelling
            self.referent = referent
        }
    }
}
extension Signature.Fragment:Sendable where Scalar:Sendable
{
}
extension Signature.Fragment:ExpressibleByStringLiteral
{
    @inlinable public
    init(stringLiteral spelling:String)
    {
        self.init(spelling)
    }
}
