extension Swiftinit.API
{
    @frozen public
    enum Get:String, Swiftinit.Method
    {
        case build
        case oldest
        case render
    }
}
