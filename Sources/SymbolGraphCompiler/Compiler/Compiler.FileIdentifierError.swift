extension Compiler
{
    public
    struct FileIdentifierError:Equatable, Error, Sendable
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
