import Grammar

/// https://httpwg.org/specs/rfc9110.html#tokens
enum MultipartTokenRule<Location>: ParsingRule {
    typealias Terminal = UInt8

    static func parse<Source>(
        _ input: inout ParsingInput<some ParsingDiagnostics<Source>>
    ) throws -> String
        where Source: Collection<UInt8>, Source.Index == Location {
        let start: Location = input.index
        try input.parse(as: CodeUnit.self)
        input.parse(as: CodeUnit.self, in: Void.self)
        return .init(decoding: input[start ..< input.index], as: Unicode.ASCII.self)
    }
}
