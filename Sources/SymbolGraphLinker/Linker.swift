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
    var scalars:[ScalarIdentifier: ScalarAddress]
    private
    var files:[FileIdentifier: FileAddress]

    public private(set)
    var graph:SymbolGraph

    private
    init(metadata:SymbolGraph.Metadata,
        context external:Compiler.Scalars.External)
    {
        self.external = external

        self.resolver = .init()
        self.scalars = .init()
        self.files = .init()

        self.graph = .init(metadata: metadata)
    }
}


extension Linker
{
    private mutating
    func index(scalar:Compiler.Scalar) throws -> ScalarAddress
    {
        let address:ScalarAddress = try self.graph.scalars.push(.init(
                virtuality: scalar.virtuality,
                phylum: scalar.phylum,
                path: scalar.path),
            id: scalar.id)
        
        self.scalars[scalar.id] = address
        return address
    }
    private mutating
    func index(extension:Compiler.Extension) throws -> ScalarAddress
    {
        let scalar:ScalarIdentifier = `extension`.signature.type.id
        return try
        {
            switch $0
            {
            case nil:
                let address:ScalarAddress = try self.graph.scalars.push(nil, id: scalar)
                $0 = address
                return address
            
            case let address?:
                return address
            }
        } (&self.scalars[scalar])
    }
}
extension Linker
{
    private mutating
    func address(of scalar:ScalarIdentifier) throws -> ScalarAddress
    {
        try
        {
            switch $0
            {
            case nil:
                let address:ScalarAddress = try self.graph.scalars.symbols(scalar)
                $0 = address
                return address
            
            case let address?:
                return address
            }
        } (&self.scalars[scalar])
    }
    private mutating
    func address(of file:FileIdentifier) throws -> FileAddress
    {
        try
        {
            switch $0
            {
            case nil:
                let address:FileAddress = try self.graph.files.symbols(file)
                $0 = address
                return address
            
            case let address?:
                return address
            }
        } (&self.files[file])
    }
}

extension Linker
{
    private mutating
    func index(scalars:[Compiler.Scalar], extensions:[Compiler.Extension]) throws
    {
        let included:[ScalarAddress] = try scalars.map
        {
            try self.index(scalar: $0)
        }
        let extended:[ScalarAddress] = try extensions.map
        {
            try self.index(extension: $0)
        }

        for (included, scalar):(ScalarAddress, Compiler.Scalar)
            in zip(included, scalars)
        {
            // let _:SourceLocation<FileAddress>? = try scalar.location?.map
            // {
            //     try self.address(of: $0)
            // }
            self.resolver.overload(scalar.path, with: .init(
                target: .scalar(included),
                phylum: scalar.phylum,
                id: scalar.resolution))
        }
        for (extended, `extension`):(ScalarAddress, Compiler.Extension)
            in zip(extended, extensions)
        {
            if  let prefix:[String] =
                self.graph.scalars[extended].local?.path.map({ $0 }) ??
                self.external[heir: `extension`.signature.type]
            {
                for feature:Symbol.Scalar in `extension`.features
                {
                    let address:ScalarAddress = try self.address(of: feature.id)
                    if  let (last, phylum):(String, ScalarPhylum) =
                        self.graph.scalars[address].local.map({ ($0.path.last, $0.phylum) }) ??
                        self.external[feature: feature]
                    {
                        let resolution:Symbol.Vector = .init(feature,
                            self: `extension`.signature.type)
                        self.resolver.overload(.init(prefix, last), with: .init(
                            target: .vector(address, self: extended),
                            phylum: phylum,
                            id: resolution))
                    }
                }
            }
            //self.graph.scalars[local: address].extensions.append(.init())
        }
    }
}
