extension Swiftinit.API
{
    @frozen public
    enum Put:String, Swiftinit.Method
    {
        case snapshot = "snapshot"
        case graph = "symbolgraph"
    }
}
