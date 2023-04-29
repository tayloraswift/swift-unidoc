import SourceMaps
import SymbolGraphParts

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<FileIdentifier>?
        public
        let comment:Compiler.Documentation.Comment?

        init?(location:SourceLocation<FileIdentifier>?, comment:Compiler.Documentation.Comment?)
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
