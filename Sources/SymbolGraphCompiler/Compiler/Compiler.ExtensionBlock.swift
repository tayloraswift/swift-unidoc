extension Compiler
{
    struct ExtensionBlock
    {
        let location:SourceLocation<String>?
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
