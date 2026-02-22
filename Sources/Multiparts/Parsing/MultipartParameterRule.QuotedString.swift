import Grammar

extension MultipartParameterRule {
    /// https://httpwg.org/specs/rfc9110.html#quoted.strings
    enum QuotedString: ParsingRule {
        typealias Terminal = UInt8

        static func parse<Source>(
            _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
        ) throws -> String
            where Source: Collection<UInt8>, Source.Index == Location {
            try input.parse(as: UnicodeEncoding.DoubleQuote.self)

            let start: Location = input.index
            input.parse(as: LiteralCharacter.self, in: Void.self)
            let end: Location = input.index

            var string: String = .init(decoding: input[start ..< end], as: Unicode.UTF8.self)

            while let next: Unicode.Scalar = input.parse(as: EscapeSequence?.self) {
                string.append(Character.init(next))

                let start: Location = input.index
                input.parse(as: LiteralCharacter.self, in: Void.self)
                let end: Location = input.index

                string += .init(decoding: input[start ..< end], as: Unicode.UTF8.self)
            }

            try input.parse(as: UnicodeEncoding.DoubleQuote.self)
            return string
        }
    }
}
