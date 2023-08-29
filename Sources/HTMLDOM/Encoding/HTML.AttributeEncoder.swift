extension HTML
{
    @dynamicMemberLookup
    @frozen public
    struct AttributeEncoder:StreamingEncoder
    {
        @usableFromInline internal
        var utf8:[UInt8]

        @inlinable internal
        init(utf8:[UInt8] = [])
        {
            self.utf8 = utf8
        }
    }
}
extension HTML.AttributeEncoder
{
    /// Serializes an empty attribute, if the assigned boolean is true.
    /// Does nothing if it is false. The getter always returns false.
    @inlinable public
    subscript(name name:HTML.Attribute) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[name: name] = bool ? "" : nil
        }
    }

    @inlinable public
    subscript(name name:HTML.Attribute) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            if  let text:String
            {
                self.utf8 += DOM.Property<HTML.Attribute>.init(name, text)
            }
        }
    }
}
extension HTML.AttributeEncoder
{
    @inlinable public
    subscript(dynamicMember path:KeyPath<HTML.Attribute.Factory, HTML.Attribute>) -> Bool
    {
        get
        {
            false
        }
        set(bool)
        {
            self[name: HTML.Attribute.Factory.init()[keyPath: path]] = bool
        }
    }
    @inlinable public
    subscript(dynamicMember path:KeyPath<HTML.Attribute.Factory, HTML.Attribute>) -> String?
    {
        get
        {
            nil
        }
        set(text)
        {
            self[name: HTML.Attribute.Factory.init()[keyPath: path]] = text
        }
    }
}
