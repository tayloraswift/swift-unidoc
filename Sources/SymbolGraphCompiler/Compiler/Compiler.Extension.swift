import SymbolColonies

extension Compiler
{
    struct Extension
    {
        var conformances:Set<SymbolIdentifier>
        var features:Set<SymbolIdentifier>
        var members:Set<SymbolIdentifier>
        var blocks:[Block]

        init(conformances:Set<SymbolIdentifier> = [],
            features:Set<SymbolIdentifier> = [],
            members:Set<SymbolIdentifier> = [],
            blocks:[Block] = [])
        {
            self.conformances = conformances
            self.features = features
            self.members = members
            self.blocks = blocks
        }
    }
}

extension Compiler.Extension
{
    mutating
    func combine(_ block:SymbolDescription) throws
    {
        guard case .extension = block.phylum
        else
        {
            throw ExtensionBlockPhylumError.init(invalid: block.phylum, usr: block.usr)
        }
        if  let block:Block = .init(location: block.location,
                text: block.documentation?.text)
        {
            self.blocks.append(block)
        }
    }
    mutating
    func insert(conformance:SymbolIdentifier)
    {
        self.conformances.insert(conformance)
    }
}
