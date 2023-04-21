extension Compiler
{
    public
    struct DuplicateBlockError:Equatable, Error
    {
        public
        init()
        {
        }
    }
}
extension Compiler.DuplicateBlockError:CustomStringConvertible
{
    public
    var description:String
    {
        "Duplicate extension block resolution."
    }
}
