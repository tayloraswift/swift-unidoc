extension HTML.AttributeEncoder
{
    @inlinable public
    var rel:HTML.Attribute.Rel?
    {
        get
        {
            nil
        }
        set(value)
        {
            self[name: .rel] = value?.rawValue
        }
    }
}
