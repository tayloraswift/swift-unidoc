import HTML
import HTTP

extension HTTP.Origin
{
    func link(_ uri:String, rel:HTML.Attribute.Rel) -> String
    {
        "<\(self)\(uri)>; rel=\"\(rel)\""
    }
}
