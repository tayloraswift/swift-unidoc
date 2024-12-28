import Grammar

extension UCF
{
    /// SignaturePattern ::= FunctionPattern | '>' TypePattern
    enum SignaturePatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> SignaturePattern where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            if  let function:(inputs:[TypePattern], output:TypePattern?) = input.parse(
                    as: FunctionPatternRule?.self)
            {
                return .function(function.inputs, function.output)
            }
            else
            {
                try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight.self)
                return .returns(try input.parse(as: TypePatternRule.self))
            }
        }
    }
}
