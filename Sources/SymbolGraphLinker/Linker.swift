import CodelinkResolution
import Declarations
import Generics
import Symbols
import SymbolGraphCompiler
import SymbolGraphParts

@_eagerMove
public
struct Linker
{
    private
    let external:Compiler.ScalarNominations

    private
    var resolver:CodelinkResolver

    private
    var scalars:[ScalarSymbol: ScalarAddress]
    private
    var files:[FileSymbol: FileAddress]

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
    /// Indexes the given scalar and appends it to the symbol graph.
    ///
    /// This function only populates basic information (flags and path)
    /// about the scalar, the rest should only be added after completing
    /// a full pass over all the scalars and extensions.
    ///
    /// This function doesn’t check for duplicates.
    private mutating
    func allocate(scalar:Compiler.Scalar) throws -> ScalarAddress
    {
        let address:ScalarAddress = try self.graph.nodes.push(.init(
                flags: .init(aperture: scalar.aperture, phylum: scalar.phylum),
                path: scalar.path),
            id: scalar.id)
        
        self.scalars[scalar.id] = address
        return address
    }
    /// Indexes the scalar extended by the given extension and appends
    /// the (empty) scalar to the symbol graph, if it has not already
    /// been indexed. (This function checks for duplicates.)
    private mutating
    func allocate(extension:Compiler.Extension) throws -> ScalarAddress
    {
        let scalar:ScalarSymbol = `extension`.extendee
        return try
        {
            switch $0
            {
            case nil:
                let address:ScalarAddress = try self.graph.nodes.push(nil, id: scalar)
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
    func intern(_ id:FileSymbol) throws -> FileAddress
    {
        try
        {
            switch $0
            {
            case nil:
                let address:FileAddress = try self.graph.files.symbols(id)
                $0 = address
                return address
            
            case let address?:
                return address
            }
        } (&self.files[id])
    }
    /// Returns the address of the scalar with the given identifier,
    /// registering it in the symbol table if needed. You should never
    /// call ``allocate(scalar:)`` or ``allocate(extension:)`` after
    /// calling this function.
    private mutating
    func intern(_ id:ScalarSymbol) throws -> ScalarAddress
    {
        try
        {
            switch $0
            {
            case nil:
                let address:ScalarAddress = try self.graph.nodes.symbols(id)
                $0 = address
                return address
            
            case let address?:
                return address
            }
        } (&self.scalars[id])
    }
}

extension Linker
{
    private mutating
    func address(of scalar:ScalarSymbol?) throws -> ScalarAddress?
    {
        try scalar.map
        {
            try self.intern($0)
        }
    }
    /// Returns an array of addresses for an array of scalar symbols.
    /// The address assignments reflect the order of the symbols in the
    /// array, so you should sort them if you want deterministic
    /// addressing.
    ///
    /// This function doesn’t expose the scalars for codelink resolution,
    /// because it is expected that the same symbols may appear in
    /// the array arguments of multiple calls to this function, and it
    /// it more efficient to expose scalars while performing a different
    /// pass.
    private mutating
    func addresses(of scalars:[ScalarSymbol]) throws -> [ScalarAddress]
    {
        try scalars.map
        {
            try self.intern($0)
        }
    }
    /// Returns an array of addresses for an array of vector features,
    /// exposing each vector for codelink resolution in the process.
    ///
    /// -   Parameters:
    ///     -   features:
    ///         An array of scalar symbols, assumed to be the feature
    ///         components of a collection of vector symbols with the
    ///         same heir.
    ///     -   prefix:
    ///         The lexical path of the shared heir.
    ///     -   extended:
    ///         The shared heir.
    ///     -   address:
    ///         The address of the shared heir.
    ///
    /// Unlike ``addresses(of:)``, this function adds overloads to the
    /// codelink resolver, because it’s more efficient to combine these
    /// two passes.
    private mutating
    func addresses(exposing features:[ScalarSymbol],
        prefixed prefix:[String],
        of extended:ScalarSymbol,
        at address:ScalarAddress) throws -> [ScalarAddress]
    {
        try features.map
        {
            let feature:ScalarAddress = try self.intern($0)
            if  let (last, phylum):(String, ScalarPhylum) =
                self.graph.nodes[feature].map({ ($0.path.last, $0.phylum) }) ??
                self.external[feature: $0]
            {
                let vector:VectorSymbol = .init($0, self: extended)
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
    /// Allocates and binds addresses for the given array of compiled scalars.
    /// (Binding consists of populating the aperture and phylum of a scalar.)
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    public mutating
    func allocate(scalars:[Compiler.Scalar]) throws -> [ScalarAddress]
    {
        try scalars.map
        {
            let address:ScalarAddress = try self.allocate(scalar: $0)
            //  Make the scalars visible to codelink resolution.
            self.resolver.overload($0.path, with: .init(
                target: .scalar(address),
                phylum: $0.phylum,
                id: $0.id))
            return address
        }
    }
    /// Allocates addresses for the given array of compiled extensions.
    ///
    /// -   Returns:
    ///     An (address, index) tuple for each compiled extension. If the
    ///     extension extends a symbol that has not yet been registered,
    ///     the address is newly allocated.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method second, after calling ``allocate(scalars:)``.
    public mutating
    func allocate(extensions:[Compiler.Extension]) throws -> [(ScalarAddress, Int)]
    {
        let addresses:[ScalarAddress] = try extensions.map
        {
            try self.allocate(extension: $0)
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

            let index:Int = self.graph.nodes[$0.0].push(.init(
                conformances: conformances,
                features: features,
                nested: nested,
                where: try $0.1.conditions.map
                {
                    try $0.map
                    {
                        try self.intern($0)
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
                try self.intern($0)
            }

            //  Sort for deterministic addresses.
            let superforms:[ScalarAddress] = try self.addresses(of: scalar.superforms.sorted())
            let features:[ScalarAddress] = try self.addresses(of: scalar.features.sorted())
            let origin:ScalarAddress? = try self.address(of: scalar.origin)

            let location:SourceLocation<FileAddress>? = try scalar.location?.map
            {
                try self.intern($0)
            }
            let article:SymbolGraph.Article? = scalar.documentation.map
            {
                var outliner:Outliner = .init(resolver: self.resolver, scope: $0.scope)
                return outliner.link(comment: $0.comment)
            }

            self.graph.nodes[address]?.declaration = declaration
            
            self.graph.nodes[address]?.superforms = superforms
            self.graph.nodes[address]?.features = features
            self.graph.nodes[address]?.origin = origin

            self.graph.nodes[address]?.location = location
            self.graph.nodes[address]?.article = article
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
                self.graph.nodes[address, index].article = outliner.link(comment: comment)
            }
        }
    }
}
