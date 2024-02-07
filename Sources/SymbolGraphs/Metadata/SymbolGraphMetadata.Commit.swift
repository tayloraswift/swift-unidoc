import SHA1

extension SymbolGraphMetadata
{
    @frozen public
    struct Commit:Equatable, Sendable
    {
        /// The git ref used to check out the original package sources, if the
        /// relevant symbol graph was generated for a source-controlled SPM package.
        /// This is an **exact** string; `v1.2.3` and  `1.2.3` are not equivalent.
        ///
        /// It’s possible for multiple commits to have the same refname. This is typical for
        /// branches.
        public
        var name:String
        /// The SHA-1 hash of the commit, nil if unknown. If the hash is unknown, the refname
        /// **must** point to a permanent tag.
        public
        var sha1:SHA1?

        @inlinable public
        init(name:String, sha1:SHA1? = nil)
        {
            self.name = name
            self.sha1 = sha1
        }
    }
}
