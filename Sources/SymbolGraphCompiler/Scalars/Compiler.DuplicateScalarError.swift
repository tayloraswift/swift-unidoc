extension Compiler
{
    public
    struct DuplicateScalarError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension Compiler.DuplicateScalarError:CustomStringConvertible
{
    public
    var description:String
    {
        "Duplicate scalar resolution."
    }
}
