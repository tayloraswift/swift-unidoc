import SHA1

extension SymbolGraphMetadata
{
    @frozen public
    struct Commit:Equatable, Sendable
    {
        /// The SHA-1 hash of the commit.
        public
        var hash:SHA1
        /// The git ref used to check out the original package sources, if the
        /// relevant symbol graph was generated for a source-controlled SPM package.
        /// This is an **exact** string; `v1.2.3` and  `1.2.3` are not equivalent.
        ///
        /// It’s possible for multiple commits to have the same refname. This is typical for
        /// branches.
        public
        var refname:String

        @inlinable public
        init(_  hash:SHA1, refname:String)
        {
            self.hash = hash
            self.refname = refname
        }
    }
}
