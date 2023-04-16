import SymbolGraphCompiler
import SymbolColonies

public
enum Linker
{
}

extension Linker
{
    static
    func link(scalars:[Compiler.Scalar], extensions:[Compiler.Extension]) throws
    {
        var addresses:AddressTable<SymbolIdentifier> = .init()
        var files:AddressTable<String> = .init()

        for scalar:Compiler.Scalar in scalars
        {
            try addresses.append(scalar.resolution.id)
        }
        for scalar:Compiler.Scalar in scalars
        {
            if  let location:SymbolDescription.Location = scalar.location,
                let position:SymbolGraph.SourcePosition = .init(line: location.line,
                    column: location.column)
            {
                let file:UInt32 = try files.address(location.file)
                let _:SymbolGraph.SourceLocation = .init(position: position, file: file)
            }
        }
        for `extension`:Compiler.Extension in extensions
        {
            _ = try addresses.address(`extension`.signature.type.id)
        }
    }
}
