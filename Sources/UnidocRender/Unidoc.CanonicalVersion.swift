import URI

extension Unidoc
{
    @frozen public
    struct CanonicalVersion
    {
        public
        let relationship:Relationship
        /// Human-oriented text to display as the name of the package.
        public
        let package:String
        /// URI to the trunk page of the canonical volume.
        public
        let volume:URI
        public
        let target:Target

        @inlinable public
        init(relationship:Relationship, package:String, volume:URI, target:Target)
        {
            self.relationship = relationship
            self.package = package
            self.volume = volume
            self.target = target
        }
    }
}
