extension Repository.Pin
{
    @frozen public
    struct State:Equatable, Hashable, Sendable
    {
        public
        let revision:Repository.Revision
        public
        let ref:Repository.Ref

        @inlinable public
        init(revision:Repository.Revision, ref:Repository.Ref)
        {
            self.revision = revision
            self.ref = ref
        }
    }
}
