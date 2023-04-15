extension Compiler.Extension
{
    @frozen public
    struct Block
    {
        public
        let location:SourceLocation<String>?
        public
        let comment:String?

        init?(location:SourceLocation<String>?, comment:String?)
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
