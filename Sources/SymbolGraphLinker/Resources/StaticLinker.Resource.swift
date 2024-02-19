extension StaticLinker
{
    struct Resource
    {
        private
        let file:any ResourceFile
        let id:Int32

        init(file:any ResourceFile, id:Int32)
        {
            self.file = file
            self.id = id
        }
    }
}
extension StaticLinker.Resource
{
    func text(trimmingTrailingNewlines:Bool = true) throws -> StaticLinker.ResourceText
    {
        .init(utf8: try self.file.read(as: [UInt8].self),
            trimmingTrailingNewlines: trimmingTrailingNewlines)
    }
}
