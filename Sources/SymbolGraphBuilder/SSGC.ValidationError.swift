extension SSGC
{
    struct ValidationError:Error
    {
    }
}
extension SSGC.ValidationError:CustomStringConvertible
{
    var description:String
    {
        "Project has at least one documentation error, see diagnostic log for details"
    }
}
