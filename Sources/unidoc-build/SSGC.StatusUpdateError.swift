extension SSGC
{
    struct StatusUpdateError:Error
    {
        init()
        {
        }
    }
}
extension SSGC.StatusUpdateError:CustomStringConvertible
{
    var description:String { "Expected a status update from SSGC" }
}
