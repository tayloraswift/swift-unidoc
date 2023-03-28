extension HTML
{
    @frozen public
    struct AttributeEncoder
    {
        @usableFromInline internal
        var string:String

        @inlinable internal
        init(string:String = "")
        {
            self.string = string
        }
    }
}
extension HTML.AttributeEncoder
{
    /// Serializes an empty attribute, if the assigned boolean is true.
    /// Does nothing if it is false. The getter always returns false.
    @inlinable public
    subscript(name:HTML.Attribute) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[name] = bool ? "" : nil
        }
    }
    @inlinable public
    subscript(name:HTML.Attribute) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self.string.append(" ")
                self.string.append(name.rawValue)
                self.string.append("='")
                for character:Character in text
                {
                    if  character == "'"
                    {
                        self.string.append("&#39;")
                    }
                    else
                    {
                        self.string.append(character)
                    }
                }
                self.string.append("'")
            }
        }
    }
}
