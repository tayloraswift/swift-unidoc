import LinkResolution
import SymbolGraphCompiler
import Symbols
import UCF

extension SSGC.Linker
{
    @_spi(testable) public
    struct Context
    {
        let id:Symbol.Module
        var causalLinks:UCF.ResolutionTable<UCF.CausalOverload>

        var extensions:[(value:SSGC.Extension, i:Int32, j:Int)]
        var decls:[(value:SSGC.Decl, i:Int32, n:Symbol.Module)]

        var resources:[String: SSGC.Resource]
        var articles:[SSGC.Article]

        @_spi(testable) public
        init(id:Symbol.Module,
            causalLinks:UCF.ResolutionTable<UCF.CausalOverload> = [:],
            extensions:[(value:SSGC.Extension, i:Int32, j:Int)] = [],
            decls:[(value:SSGC.Decl, i:Int32, n:Symbol.Module)] = [],
            resources:[String: SSGC.Resource] = [:],
            articles:[SSGC.Article] = [])
        {
            self.id = id
            self.causalLinks = causalLinks

            self.extensions = extensions
            self.decls = decls

            self.resources = resources
            self.articles = articles
        }
    }
}
