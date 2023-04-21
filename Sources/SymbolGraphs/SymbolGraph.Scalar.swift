extension SymbolGraph
{
    @frozen public
    struct Scalar
    {
        public
        let virtuality:Virtuality?
        public
        let phylum:Phylum
        public
        let path:LexicalPath

        public
        let generics:GenericSignature<UInt32>
        public
        let location:SourceLocation<UInt32>?
    }
}
