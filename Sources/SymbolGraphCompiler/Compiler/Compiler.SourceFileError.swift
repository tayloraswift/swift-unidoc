extension Compiler
{
    public
    struct SourceFileError:Equatable, Error, Sendable
    {
        public
        let uri:String

        public
        init(invalid uri:String)
        {
            self.uri = uri
        }
    }
}
extension Compiler.SourceFileError:CustomStringConvertible
{
    public
    var description:String
    {
        "Invalid source file uri '\(self.uri)'."
    }
}
