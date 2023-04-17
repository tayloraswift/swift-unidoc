import SymbolDescriptions

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:Compiler.Location?
        public
        let comment:String?

        init?(location:Compiler.Location?, comment:String?)
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
