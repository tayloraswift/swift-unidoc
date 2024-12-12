import SHA1
import UnixTime

extension SymbolGraphMetadata
{
    @frozen public
    struct Commit:Equatable, Sendable
    {
        /// The git ref used to check out the original package sources, if the
        /// relevant symbol graph was generated for a source-controlled SwiftPM package.
        /// This is an **exact** string; `v1.2.3` and  `1.2.3` are not equivalent.
        ///
        /// It’s possible for multiple commits to have the same ref name. This is typical for
        /// branches.
        ///
        /// It’s also possible for a commit to have multiple ref names. The name stored here
        /// is whatever SwiftPM used to check out the sources.
        public
        var name:String
        /// The SHA-1 hash of the commit, nil if unknown. If the hash is unknown, the refname
        /// **must** point to a permanent tag.
        public
        var sha1:SHA1?
        /// The date of the commit, if known.
        public
        var date:UnixMillisecond?

        @inlinable public
        init(name:String, sha1:SHA1? = nil, date:UnixMillisecond? = nil)
        {
            self.name = name
            self.sha1 = sha1
            self.date = date
        }
    }
}
