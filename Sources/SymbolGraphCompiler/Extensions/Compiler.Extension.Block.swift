import Sources
import SymbolGraphParts
import Symbols

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<Symbol.File>?
        public
        let comment:Compiler.Doccomment?

        init?(location:SourceLocation<Symbol.File>?, comment:Compiler.Doccomment?)
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
