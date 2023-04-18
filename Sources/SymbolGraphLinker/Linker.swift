import SymbolGraphCompiler
import SymbolDescriptions

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
        var files:AddressTable<FileIdentifier> = .init()

        for scalar:Compiler.Scalar in scalars
        {
            try addresses.append(scalar.resolution.id)
        }
        for scalar:Compiler.Scalar in scalars
        {
            if  let location:SourceLocation<FileIdentifier> = scalar.location
            {
                let file:UInt32 = try files.address(location.file)
                let _:SourceLocation<UInt32> = .init(position: location.position,
                    file: file)
            }
            let _:GenericSignature<UInt32> = try scalar.generics.map
            {
                try addresses.address($0.id)
            }
        }
        for `extension`:Compiler.Extension in extensions
        {
            _ = try addresses.address(`extension`.signature.type.id)
        }
    }
}
