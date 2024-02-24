import Sources
import SymbolGraphParts
import Symbols

extension SSGC.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<Symbol.File>?
        public
        let comment:SSGC.DocumentationComment?

        init?(location:SourceLocation<Symbol.File>?, comment:SSGC.DocumentationComment?)
        {
            if case (nil, nil) = (location, comment)
            {
                return nil
            }
            else
            {
                self.location = location
                self.comment = comment
            }
        }
    }
}
