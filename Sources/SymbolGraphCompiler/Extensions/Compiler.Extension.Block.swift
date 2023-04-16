import SymbolColonies

extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SymbolDescription.Location?
        public
        let comment:String?

        init?(location:SymbolDescription.Location?, comment:String?)
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
