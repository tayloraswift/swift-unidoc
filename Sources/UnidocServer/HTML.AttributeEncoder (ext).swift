import HTML
import HTTPServer

extension HTML.AttributeEncoder
{
    var rel:ServerResourceRelationship?
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
