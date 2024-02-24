extension HTML.Attribute.Factory
{
    @available(*, unavailable,
        message: "Use the typed 'property' property on 'HTML.AttributeEncoder' instead.")
    @inlinable public
    var property:HTML.Attribute { .property }

    @available(*, unavailable,
        message: "Use the typed 'rel' property on 'HTML.AttributeEncoder' instead.")
    @inlinable public
    var rel:HTML.Attribute { .rel }
}
