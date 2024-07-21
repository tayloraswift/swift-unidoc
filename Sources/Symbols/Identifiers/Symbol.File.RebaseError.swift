extension Symbol.File
{
    @frozen public
    struct RebaseError:Equatable, Error
    {
        public
        let base:Symbol.FileBase
        public
        let path:String

        @inlinable public
        init(base:Symbol.FileBase, path:String)
        {
            self.base = base
            self.path = path
        }
    }
}
extension Symbol.File.RebaseError:CustomStringConvertible
{
    public
    var description:String
    {
        "Cannot rebase '\(self.path)' against '\(self.base)'"
    }
}
