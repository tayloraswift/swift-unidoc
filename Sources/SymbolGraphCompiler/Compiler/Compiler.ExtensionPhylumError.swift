extension Compiler
{
    public
    struct ExtensionPhylumError:Equatable, Error
    {
        public
        let phylum:SymbolPhylum
        public
        let block:BlockSymbolResolution

        public
        init(invalid phylum:SymbolPhylum, block:BlockSymbolResolution)
        {
            self.phylum = phylum
            self.block = block
        }
    }
}
extension Compiler.ExtensionPhylumError:CustomStringConvertible
{
    public
    var description:String
    {
        "Extension block '\(self.block)' has invalid phylum '\(self.phylum)'."
    }
}
