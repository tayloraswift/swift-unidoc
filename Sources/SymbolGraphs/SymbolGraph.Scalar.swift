import Generics
import LexicalPaths
import SourceMaps

extension SymbolGraph
{
    @frozen public
    struct Scalar
    {
        public
        let virtuality:ScalarPhylum.Virtuality?
        public
        let phylum:ScalarPhylum
        public
        let path:LexicalPath

        public
        let generics:GenericSignature<ScalarAddress>
        public
        let location:SourceLocation<FileAddress>?
    }
}
