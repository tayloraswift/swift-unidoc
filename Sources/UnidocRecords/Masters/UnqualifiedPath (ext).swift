import LexicalPaths

extension UnqualifiedPath
{
    @inlinable public
    init?(splitting stem:Record.Stem)
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
