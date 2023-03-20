extension Compiler.Extension
{
    struct Block
    {
        let location:SourceLocation<String>?
        let text:String?

        init?(location:SourceLocation<String>?, text:String?)
        {
            if case (nil, nil) = (location, text)
            {
                return nil
            }
            else
            {            
                self.location = location
                self.text = text
            }
        }
    }
}
