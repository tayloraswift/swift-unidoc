import Grammar

extension UCF
{
    /// Arrow ::= \s * '->' \s *
    enum ArrowRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Source>(
            _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws
            where Source:Collection<Terminal>, Source.Index == Location
        {
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.Hyphen.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight.self)
            input.parse(as: UnicodeEncoding<Location, Terminal>.Space.self, in: Void.self)
        }
    }
}
