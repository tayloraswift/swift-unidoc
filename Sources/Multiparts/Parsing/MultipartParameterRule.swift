import Grammar

enum MultipartParameterRule<Location>: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws -> (
        name: String,
        value: String
    )
        where Source: Collection<UInt8>, Source.Index == Location {
        input.parse(as: HorizontalWhitespaceRule.self, in: Void.self)

        try input.parse(as: UnicodeEncoding.Semicolon.self)

        input.parse(as: HorizontalWhitespaceRule.self, in: Void.self)

        let name: String = try input.parse(as: MultipartTokenRule.self)

        try input.parse(as: UnicodeEncoding.Equals.self)

        if  let value: String = input.parse(as: MultipartTokenRule?.self) {
            return (name.lowercased(), value)
        } else {
            return (name.lowercased(), try input.parse(as: QuotedString.self))
        }
    }
}
