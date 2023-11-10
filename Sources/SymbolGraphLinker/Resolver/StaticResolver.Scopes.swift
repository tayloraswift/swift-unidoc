import CodelinkResolution
import DoclinkResolution

extension StaticResolver
{
    struct Scopes
    {
        let codelink:CodelinkResolver<Int32>.Scope
        let doclink:DoclinkResolver.Scope

        init(codelink:CodelinkResolver<Int32>.Scope, doclink:DoclinkResolver.Scope)
        {
            self.codelink = codelink
            self.doclink = doclink
        }
    }
}
