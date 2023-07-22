extension Unidoc
{
    @frozen public
    struct Vector:Equatable, Hashable, Sendable
    {
        public
        let sub:Scalar
        public
        let dom:Scalar

        @inlinable public
        init(sub:Scalar, dom:Scalar)
        {
            self.sub = sub
            self.dom = dom
        }
    }
}
