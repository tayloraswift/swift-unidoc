import CodelinkResolution
import Generics
import SourceMaps
import SymbolGraphCompiler
import SymbolGraphParts

public
struct Linker
{
    private
    let external:Compiler.Scalars.External

    private
    var resolver:CodelinkResolver

    private
    var scalars:AddressTable<ScalarAddress>
    private
    var files:AddressTable<FileAddress>

    private
    init(context external:Compiler.Scalars.External)
    {
        self.external = external

        self.resolver = .init()
        self.scalars = .init()
        self.files = .init()
    }
}

extension Linker
{

}
extension Linker
{
    private mutating
    func index(scalars:[Compiler.Scalar], extensions:[Compiler.Extension]) throws
    {
        for scalar:Compiler.Scalar in scalars
        {
            let address:ScalarAddress = try self.scalars.append(scalar.resolution.id)

            let _:SourceLocation<FileAddress>? = try scalar.location?.map
            {
                try self.files.address($0)
            }

            self.resolver.overload(scalar.path, with: .init(target: .scalar(address),
                phylum: scalar.phylum,
                id: scalar.id))
        }
        for `extension`:Compiler.Extension in extensions
        {
            let address:ScalarAddress = try self.scalars.address(`extension`.signature.type.id)
            self.scalars[`extension`.signature.type.id]
        }
    }
}
