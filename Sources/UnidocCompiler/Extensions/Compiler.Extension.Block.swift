import Sources
import Symbols
import SymbolGraphParts

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<FileSymbol>?
        public
        let comment:Compiler.Documentation.Comment?

        init?(location:SourceLocation<FileSymbol>?, comment:Compiler.Documentation.Comment?)
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
