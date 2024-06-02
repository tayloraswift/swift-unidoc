import UnidocRecords

extension Unidoc
{
    @frozen public
    struct PackageRulers
    {
        public
        let editors:[Account]
        public
        let owner:Account?

        @inlinable public
        init(editors:[Account], owner:Account?)
        {
            self.editors = editors
            self.owner = owner
        }
    }
}
