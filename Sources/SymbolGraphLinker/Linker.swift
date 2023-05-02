import CodelinkResolution
import Declarations
import Generics
import SourceMaps
import SymbolGraphCompiler
import SymbolGraphParts

public
struct Linker
{
    private
    let external:Compiler.ScalarNominations

    private
    var resolver:CodelinkResolver

    private
    var scalars:[ScalarIdentifier: ScalarAddress]
    private
    var files:[FileIdentifier: FileAddress]

    public private(set)
    var graph:SymbolGraph

    public
    init(metadata:SymbolGraph.Metadata, context external:Compiler.ScalarNominations)
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
    static
    func _link(metadata:SymbolGraph.Metadata,
        context:Compiler.ScalarNominations,
        scalars:[Compiler.Scalar],
        extensions:[Compiler.Extension]) throws -> SymbolGraph
    {
        var linker:Self = .init(metadata: metadata, context: context)

        let scalarAddresses:[ScalarAddress] = try linker.register(
            scalars: scalars)
        let extensionAddresses:[(ScalarAddress, Int)] = try linker.register(
            extensions: extensions)

        try linker.link(scalars: scalars, at: scalarAddresses)
        try linker.link(extensions: extensions, at: extensionAddresses)

        return linker.graph
    }
}
extension Linker
{
    /// Indexes the given scalar and appends it to the symbol graph.
    ///
    /// This function only populates basic information about the scalar,
    /// the rest should only be added after completing a full pass over
    /// all the scalars and extensions.
    ///
    /// This function doesn’t check for duplicates.
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
    /// Indexes the scalar extended by the given extension and appends
    /// the (empty) scalar to the symbol graph, if it has not already
    /// been indexed. (This function checks for duplicates.)
    private mutating
    func index(extension:Compiler.Extension) throws -> ScalarAddress
    {
        let scalar:ScalarIdentifier = `extension`.extendee.id
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
    /// Returns the address of the file with the given identifier,
    /// registering it in the symbol table if needed.
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
    /// Returns the address of the scalar with the given identifier,
    /// registering it in the symbol table if needed. You should never
    /// call ``index(scalar:)`` or ``index(extension:)`` after calling
    /// this function.
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
}

extension Linker
{
    private mutating
    func addresses(of scalars:[Symbol.Scalar]) throws -> [ScalarAddress]
    {
        try scalars.map
        {
            try self.address(of: $0.id)
        }
    }
    private mutating
    func addresses(exposing features:[Symbol.Scalar],
        prefixed prefix:[String],
        of extended:Symbol.Scalar,
        at address:ScalarAddress) throws -> [ScalarAddress]
    {
        try features.map
        {
            let feature:ScalarAddress = try self.address(of: $0.id)
            if  let (last, phylum):(String, ScalarPhylum) =
                self.graph.scalars[feature].map({ ($0.path.last, $0.phylum) }) ??
                self.external[feature: $0]
            {
                let vector:Symbol.Vector = .init($0, self: extended)
                self.resolver.overload(.init(prefix, last), with: .init(
                    target: .vector(feature, self: address),
                    phylum: phylum,
                    id: vector))
            }
            return feature
        }
    }
}
extension Linker
{
    public mutating
    func register(scalars:[Compiler.Scalar]) throws -> [ScalarAddress]
    {
        try scalars.map
        {
            let address:ScalarAddress = try self.index(scalar: $0)
            //  Make the scalars visible to codelink resolution.
            self.resolver.overload($0.path, with: .init(
                target: .scalar(address),
                phylum: $0.phylum,
                id: $0.resolution))
            return address
        }
    }
    public mutating
    func register(extensions:[Compiler.Extension]) throws -> [(ScalarAddress, Int)]
    {
        let addresses:[ScalarAddress] = try extensions.map
        {
            try self.index(extension: $0)
        }
        return try zip(addresses, extensions).map
        {
            //  Sort *then* address, since we want deterministic addresses too.
            let conformances:[ScalarAddress] = try self.addresses(
                of: $0.1.conformances.sorted())
            let features:[ScalarAddress] = try self.addresses(
                exposing: $0.1.features.sorted(),
                prefixed: $0.1.path,
                of: $0.1.extendee,
                at: $0.0)
            let nested:[ScalarAddress] = try self.addresses(
                of: $0.1.nested.sorted())

            let index:Int = self.graph.scalars[$0.0].push(.init(
                conformances: conformances,
                features: features,
                nested: nested,
                where: try $0.1.conditions.map
                {
                    try $0.map
                    {
                        try self.address(of: $0.id)
                    }
                }))
            return ($0.0, index)
        }
    }
}
extension Linker
{
    public mutating
    func link(scalars:[Compiler.Scalar], at addresses:[ScalarAddress]) throws
    {
        for (address, scalar):(ScalarAddress, Compiler.Scalar) in zip(addresses, scalars)
        {
            let declaration:Declaration<ScalarAddress> = try scalar.declaration.map
            {
                try self.address(of: $0.id)
            }
            let location:SourceLocation<FileAddress>? = try scalar.location?.map
            {
                try self.address(of: $0)
            }
            let article:SymbolGraph.Article<SymbolGraph.Referent>? = scalar.documentation.map
            {
                var outliner:Outliner = .init(resolver: self.resolver, scope: $0.scope)
                return outliner.link(comment: $0.comment)
            }

            self.graph.scalars[address]?.declaration = declaration
            self.graph.scalars[address]?.location = location
            self.graph.scalars[address]?.article = article
        }
    }
    public mutating
    func link(extensions:[Compiler.Extension], at addresses:[(ScalarAddress, Int)]) throws
    {
        for ((address, index), `extension`):((ScalarAddress, Int), Compiler.Extension)
            in zip(addresses, extensions)
        {
            //  Extensions can have many constituent extension blocks, each potentially
            //  with its own doccomment. It’s not clear to me how to combine them,
            //  so for now, we just keep the longest doccomment and discard all the others,
            //  like DocC does. (Except DocC does this across all extensions with the
            //  same extended type.)
            //  https://github.com/apple/swift-docc/pull/369
            var comment:Compiler.Documentation.Comment? = nil
            var longest:Int = 0
            for block:Compiler.Extension.Block in `extension`.blocks
            {
                if  let current:Compiler.Documentation.Comment = block.comment
                {
                    //  This is really, really stupid, but we need a way to break
                    //  ties, and we can’t use source location for this, as it is
                    //  not always available.
                    let length:Int = current.text.count
                    if (longest, comment?.text ?? "") < (length, current.text)
                    {
                        longest = length
                        comment = current
                    }
                }
            }
            if  let comment
            {
                var outliner:Outliner = .init(resolver: self.resolver, scope: `extension`.path)
                self.graph.scalars[address, index].article = outliner.link(comment: comment)
            }
        }
    }
}
