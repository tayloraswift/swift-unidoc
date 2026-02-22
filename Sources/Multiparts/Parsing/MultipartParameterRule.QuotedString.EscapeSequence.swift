import Grammar

extension MultipartParameterRule.QuotedString {
    enum EscapeSequence: ParsingRule {
        typealias Terminal = UInt8

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws -> Unicode.Scalar
            where Source: Collection<UInt8>, Source.Index == Location {
            try input.parse(as: UnicodeEncoding.Backslash.self)
            return try input.parse(as: EscapedCharacter.self)
        }
    }
}
