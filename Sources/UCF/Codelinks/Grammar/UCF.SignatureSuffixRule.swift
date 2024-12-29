import Grammar

extension UCF
{
    /// SignatureSuffix ::= '-' FunctionPattern | '->' TypePattern
    enum SignatureSuffixRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Diagnostics>(
            _ input:inout ParsingInput<Diagnostics>) throws -> SignaturePattern where
            Diagnostics:ParsingDiagnostics,
            Diagnostics.Source.Element == Terminal,
            Diagnostics.Source.Index == Location
        {
            try input.parse(as: UnicodeEncoding<Location, Terminal>.Hyphen.self)
            if  case ()? = input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight?.self)
            {
                return .returns(try input.parse(as: TypePatternRule.self))
            }
            else
            {
                let function:(inputs:[TypePattern], output:TypePattern?) = try input.parse(
                    as: FunctionPatternRule.self)
                return .function(function.inputs, function.output)
            }
        }
    }
}
