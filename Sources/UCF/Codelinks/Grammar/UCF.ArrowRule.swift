import Grammar

extension UCF
{
    enum ArrowRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Source>(
            _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws
            where Source:Collection<Terminal>, Source.Index == Location
        {
            try input.parse(as: UnicodeEncoding<Location, Terminal>.Hyphen.self)
            try input.parse(as: UnicodeEncoding<Location, Terminal>.AngleRight.self)
        }
    }
}
