extension Repository.Pin
{
    @frozen public
    struct State
    {
        public
        let reference:Repository.Reference
        public
        let revision:Repository.Revision

        @inlinable public
        init(reference:Repository.Reference, revision:Repository.Revision)
        {
            self.reference = reference
            self.revision = revision
        }
    }
}
