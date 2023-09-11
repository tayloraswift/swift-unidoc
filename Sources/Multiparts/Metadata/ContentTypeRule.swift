import Grammar
import Media

enum ContentTypeRule<Location>:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(_ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> ContentType?
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let first:String = try input.parse(as: MultipartTokenRule.self)
        try input.parse(as: UnicodeEncoding.Slash.self)
        let second:String = try input.parse(as: MultipartTokenRule.self)

        //  Capture interesting parameters
        var boundary:String? = nil
        var charset:MediaType.Charset? = nil

        while let (key, value):(String, String) = input.parse(as: MultipartParameterRule?.self)
        {
            //  Note: key is already lowercased!
            switch key
            {
            case "boundary":    boundary = value
            case "charset":     charset = .init(value)
            case _:             continue
            }
        }

        var subtype:MediaSubtype? { .init(second) }

        switch first.lowercased()
        {
        case "application": return subtype.map { .media(.application($0, charset: charset)) }
        case "audio":       return subtype.map { .media(.audio      ($0, charset: charset)) }
        case "font":        return subtype.map { .media(.font       ($0, charset: charset)) }
        case "image":       return subtype.map { .media(.image      ($0, charset: charset)) }
        case "model":       return subtype.map { .media(.model      ($0, charset: charset)) }
        case "text":        return subtype.map { .media(.text       ($0, charset: charset)) }
        case "video":       return subtype.map { .media(.video      ($0, charset: charset)) }

        case "multipart":
            switch second.lowercased()
            {
            case "byteranges":
                return .multipart(.byteranges(boundary: boundary))

            case "form-data":
                return .multipart(.form_data(boundary: boundary))

            case _:
                return nil
            }

        case _: return nil
        }
    }
}
