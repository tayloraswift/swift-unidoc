extension Duration.DynamicFormat
{
    @frozen public
    enum Unit:Equatable
    {
        case seconds
        case minutes
        case hours
        case days
    }
}
