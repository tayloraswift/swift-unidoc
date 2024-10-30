import FNV1
import UnidocAPI

extension Unidoc
{
    @frozen public
    struct VertexPath:Equatable, Hashable, Sendable
    {
        /// This is not a ``Stem``, because it is case-folded.
        public
        let stem:String
        public
        let hash:FNV24?

        @inlinable public
        init(stem:String, hash:FNV24?)
        {
            self.stem = stem
            self.hash = hash
        }
    }
}
extension Unidoc.VertexPath
{
    @inlinable public
    init(casefolded path:borrowing ArraySlice<String>, hash:FNV24? = nil)
    {
        let joined:Unidoc.Stem = .init(path: path)
        self.init(stem: joined.rawValue, hash: hash)
    }

    @inlinable public
    init(casefolding shoot:Unidoc.Shoot)
    {
        //  Note: This is supposed to match the behavior of the URL router.
        self.init(stem: shoot.stem.rawValue.lowercased(), hash: shoot.hash)
    }
}
