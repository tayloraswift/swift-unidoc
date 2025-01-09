extension Markdown.BlockCodeReference
{
    enum SemanticError:Error
    {
        case resetContradictsBase
    }
}
extension Markdown.BlockCodeReference.SemanticError:CustomStringConvertible
{
    var description:String
    {
        switch self
        {
        case .resetContradictsBase:
            """
            'reset' cannot be used with 'base' (a.k.a. 'previousFile')
            """
        }
    }
}
