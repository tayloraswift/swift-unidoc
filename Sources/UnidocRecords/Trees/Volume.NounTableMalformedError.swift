extension Volume
{
    @frozen public
    enum NounTableMalformedError:Error, Equatable, Sendable
    {
        case unterminatedCustomText
        case unterminatedRow
    }
}
