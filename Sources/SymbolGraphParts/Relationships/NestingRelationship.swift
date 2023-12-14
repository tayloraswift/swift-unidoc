import Symbols

public
protocol NestingRelationship:SymbolRelationship
{
    var scope:Symbol.USR { get }

    var kinks:Phylum.Decl.Kinks { get }

    func validate(source phylum:Phylum.Decl) -> Bool
}
