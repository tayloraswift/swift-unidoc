import Grammar

extension UCF
{
    /// TypePattern ::= TypeElement ( \s * '&' \s * TypeElement ) *
    enum TypePatternRule:ParsingRule
    {
        typealias Location = String.Index
        typealias Terminal = Unicode.Scalar

        static func parse<Source>(
            _ input:inout ParsingInput<some ParsingDiagnostics<Source>>) throws -> TypePattern
            where Source:Collection<Terminal>, Source.Index == Location
        {
            let elements:[TypeElement] = try input.parse(as: Pattern.Join<TypeElementRule,
                Pattern.Pad<
                    UnicodeEncoding<Location, Terminal>.Ampersand,
                    UnicodeEncoding<Location, Terminal>.Space>,
                [TypeElement]>.self)

            return .init(composition: elements)
        }
    }
}
