import Grammar

enum MultipartHeaderRule:ParsingRule
{
    typealias Location = Int
    typealias Terminal = UInt8

    static
    func parse<Source>(_ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> (disposition:ContentDisposition?, type:ContentType?)
        where Source:Collection<UInt8>, Source.Index == Location
    {
        var disposition:ContentDisposition? = nil
        var type:ContentType? = nil

        while case (let field, _)? = try? input.parse(
                    as: (MultipartTokenRule, UnicodeEncoding.Colon).self)
        {
            input.parse(as: HorizontalWhitespaceRule.self, in: Void.self)

            switch field.lowercased()
            {
            case "content-disposition":
                disposition = try input.parse(as: ContentDispositionRule.self)
                input.parse(as: HorizontalWhitespaceRule.self, in: Void.self)

            case "content-type":
                type = try input.parse(as: ContentTypeRule.self)
                input.parse(as: HorizontalWhitespaceRule.self, in: Void.self)

            default:
                //  will also consume horizontal whitespace
                input.parse(as: OpaqueFieldValue.self, in: Void.self)
            }

            try input.parse(as: UnicodeEncoding.CarriageReturn.self)
            try input.parse(as: UnicodeEncoding.Linefeed.self)
        }

        try input.parse(as: UnicodeEncoding.CarriageReturn.self)
        try input.parse(as: UnicodeEncoding.Linefeed.self)

        return (disposition, type)
    }
}
