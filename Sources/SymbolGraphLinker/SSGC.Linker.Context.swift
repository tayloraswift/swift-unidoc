import SymbolGraphCompiler
import Symbols 
import UCF 

extension SSGC.Linker
{
    struct Context
    {
        var extensions:[(value:SSGC.Extension, i:Int32, j:Int)]
        var decls:[(value:SSGC.Decl, i:Int32, n:Symbol.Module)]

        var resources:[String: SSGC.Resource]
        var overloads:UCF.ResolutionTable<SSGC.Overload>

        var articles:[SSGC.Article]

        init()
        {
            self.extensions = []
            self.decls = []

            self.resources = [:]
            self.overloads = [:]

            self.articles = []
        }
    }
}
