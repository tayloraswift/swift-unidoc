import Availability
import Declarations
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
        var declaration:Declaration<ScalarAddress>
        public
        var location:SourceLocation<FileAddress>?

        public
        var article:Article<Referent>?

        @inlinable public
        init(virtuality:ScalarPhylum.Virtuality?, phylum:ScalarPhylum, path:LexicalPath)
        {
            self.virtuality = virtuality
            self.phylum = phylum
            self.path = path

            self.declaration = .init()

            self.location = nil
            self.article = nil
        }
    }
}
