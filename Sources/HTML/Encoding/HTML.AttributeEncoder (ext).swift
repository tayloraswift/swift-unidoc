extension HTML.AttributeEncoder
{
    @inlinable public
    var property:HTML.Attribute.Property?
    {
        get { nil }
        set (value)
        {
            self[name: .property] = value?.rawValue
        }
    }

    @inlinable public
    var rel:HTML.Attribute.Rel?
    {
        get { nil }
        set (value)
        {
            self[name: .rel] = value?.rawValue
        }
    }
}
