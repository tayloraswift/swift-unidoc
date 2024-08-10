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
        var articles:[SSGC.Article]

        var causalLinks:UCF.ResolutionTable<UCF.CausalOverload>

        init()
        {
            self.extensions = []
            self.decls = []

            self.resources = [:]
            self.articles = []
            self.causalLinks = [:]
        }
    }
}
