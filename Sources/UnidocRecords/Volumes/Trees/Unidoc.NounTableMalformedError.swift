extension Unidoc
{
    @frozen public
    enum NounTableMalformedError:Error, Equatable, Sendable
    {
        case missingTrailer
        case unterminatedCustomText
        case unterminatedRow
    }
}
