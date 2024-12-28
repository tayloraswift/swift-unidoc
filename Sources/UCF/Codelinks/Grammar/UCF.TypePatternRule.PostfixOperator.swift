import Grammar

extension UCF.TypePatternRule
{
    /// PostfixOperator ::= '?' | '!' | '.Type'
    enum PostfixOperator:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> UCF.TypeOperator where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            if  let codepoint:UCF.TypeOperator = input.parse(as: PostfixOperatorCodepoint?.self)
            {
                return codepoint
            }
            else
            {
                try input.parse(as: UnicodeEncoding<Location, Terminal>.Period.self)
                try input.parse(as: UnicodeEncoding<Location, Terminal>.UppercaseT.self)
                try input.parse(as: UnicodeEncoding<Location, Terminal>.LowercaseY.self)
                try input.parse(as: UnicodeEncoding<Location, Terminal>.LowercaseP.self)
                try input.parse(as: UnicodeEncoding<Location, Terminal>.LowercaseE.self)

                return .metatype
            }
        }
    }
}
