import CodelinkResolution
import Generics
import SourceMaps
import SymbolGraphCompiler
import SymbolGraphParts

public
enum Linker
{
}

extension Linker
{
    static
    func link(scalars:[Compiler.Scalar], extensions:[Compiler.Extension]) throws
    {
        var addresses:AddressTable<ScalarAddress> = .init()
        var files:AddressTable<FileAddress> = .init()

        var resolver:CodelinkResolver = .init()

        for scalar:Compiler.Scalar in scalars
        {
            let address:ScalarAddress = try addresses.append(scalar.resolution.id)
            
            resolver.overload(scalar.path, with: .init(target: .scalar(address),
                phylum: scalar.phylum,
                id: scalar.resolution.id.rawValue))
        }
        for scalar:Compiler.Scalar in scalars
        {
            let _:SourceLocation<FileAddress>? = try scalar.location?.map
            {
                try files.address($0)
            }
            let _:GenericSignature<ScalarAddress> = try scalar.generics.map
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
