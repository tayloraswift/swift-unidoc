import SymbolDescriptions

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<FileIdentifier>?
        public
        let comment:String?

        init?(location:SourceLocation<FileIdentifier>?, comment:String?)
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
