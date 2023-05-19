import Grammar

enum ContentDispositionRule<Location>:ParsingRule
{
    typealias Terminal = UInt8

    static
    func parse<Source>(
        _ input:inout ParsingInput<some ParsingDiagnostics<Source>>)
        throws -> ContentDisposition?
        where Source:Collection<UInt8>, Source.Index == Location
    {
        let keyword:String = try input.parse(as: MultipartTokenRule.self)

        //  Capture interesting parameters
        var filename:String? = nil
        var name:String? = nil

        while let (key, value):(String, String) = input.parse(as: MultipartParameterRule?.self)
        {
            //  Note: key is already lowercased!
            switch key
            {
            case "filename":    filename = value
            case "name":        name = value
            case _:             continue
            }
        }

        switch keyword.lowercased()
        {
        case "inline":      return .inline
        case "attachment":  return .attachment(filename: filename)
        case "form-data":
            if  let name:String
            {
                return .formData(filename: filename, name: name)
            }
            else
            {
                return nil
            }
        case _: return nil
        }
    }
}
