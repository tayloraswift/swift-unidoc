import LexicalPaths

extension UnqualifiedPath
{
    /// Extracts the path components of the given stem, skipping the prefixed namespace
    /// qualifier. Returns nil if the stem contains a namespace qualifier only.
    @inlinable public
    init?(splitting stem:Unidoc.Stem)
    {
        if  let separator:String.Index = stem.rawValue.firstIndex(where: \.isWhitespace)
        {
            self.init(
                splitting: stem.rawValue[stem.rawValue.index(after: separator)...],
                where: \.isWhitespace)
        }
        else
        {
            return nil
        }
    }
}
