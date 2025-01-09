extension Markdown.BlockLeaf
{
    enum StructuralError:Error
    {
        case childUnexpected
    }
}
extension Markdown.BlockLeaf.StructuralError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .childUnexpected:
            """
            block directive of this type cannot contain child blocks
            """
        }
    }
}
