import CodelinkResolution
import Declarations
import Generics
import ModuleGraphs
import Symbols
import SymbolGraphs
import UnidocCompiler

public
struct StaticLinker
{
    public private(set)
    var docs:Documentation

    private
    let nominations:Compiler.Nominations

    private
    var resolver:StaticResolver

    /// Interned module names. This only contains modules that
    /// are not included in the symbol graph being linked.
    private
    var modules:[ModuleIdentifier: Int]
    private
    var scalars:[ScalarSymbol: ScalarAddress]
    private
    var files:[FileSymbol: FileAddress]

    public
    init(nominations:Compiler.Nominations,
        modules:[ModuleDetails])
    {
        self.docs = .init(modules: modules)

        self.nominations = nominations

        self.resolver = .init()

        self.modules = [:]
        self.scalars = [:]
        self.files = [:]
    }
}
extension StaticLinker
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
        let address:ScalarAddress = try self.docs.graph.append(.init(
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
        let scalar:ScalarSymbol = `extension`.extended.type
        return try
        {
            switch $0
            {
            case nil:
                let address:ScalarAddress = try self.docs.graph.append(nil, id: scalar)
                $0 = address
                return address

            case let address?:
                return address
            }
        } (&self.scalars[scalar])
    }
}
extension StaticLinker
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
                let address:FileAddress = try self.docs.files.symbols.append(id)
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
                let address:ScalarAddress = try self.docs.graph.symbols.append(id)
                $0 = address
                return address

            case let address?:
                return address
            }
        } (&self.scalars[id])
    }

    private mutating
    func intern(_ id:ModuleIdentifier) -> Int
    {
        {
            switch $0
            {
            case nil:
                let index:Int = self.docs.graph.append(id)
                $0 = index
                return index

            case let index?:
                return index
            }
        } (&self.modules[id])
    }
    private mutating
    func intern(_ id:Compiler.Namespace.ID) -> Int
    {
        switch id
        {
        case .index(let culture):   return culture
        case .nominated(let id):    return self.intern(id)
        }
    }
}

extension StaticLinker
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
        prefixed prefix:(ModuleIdentifier, [String]),
        of extended:ScalarSymbol,
        at address:ScalarAddress) throws -> [ScalarAddress]
    {
        try features.map
        {
            let feature:ScalarAddress = try self.intern($0)
            if  let (last, phylum):(String, ScalarPhylum) =
                self.docs.graph[feature]?.scalar.map({ ($0.path.last, $0.phylum) }) ??
                self.nominations[feature: $0]
            {
                let vector:VectorSymbol = .init($0, self: extended)
                self.resolver.overload(prefix.0 / .init(prefix.1, last), with: .init(
                    target: .vector(feature, self: address),
                    phylum: phylum,
                    id: vector))
            }
            return feature
        }
    }
}
extension StaticLinker
{
    private mutating
    func allocate(scalars:[Compiler.Scalar]) throws -> ClosedRange<ScalarAddress>
    {
        var addresses:(first:ScalarAddress, last:ScalarAddress)? = nil
        for scalar:Compiler.Scalar in scalars
        {
            let address:ScalarAddress = try self.allocate(scalar: scalar)
            switch addresses
            {
            case  nil:              addresses = (address, address)
            case (let first, _)?:   addresses = (first,   address)
            }
        }
        if  case (let first, let last)? = addresses
        {
            return first ... last
        }
        else
        {
            fatalError("cannot allocate empty scalar array")
        }
    }
    /// Allocates and binds addresses for the scalars stored in the given array
    /// of compiled namespaces. (Binding consists of populating the aperture and
    /// phylum of a scalar.) This function also exposes each of the scalars for
    /// codelink resolution.
    ///
    /// For best results (smallest/most-orderly linked symbolgraph), you should
    /// call this method first, before calling any others.
    public mutating
    func allocate(namespaces:[[Compiler.Namespace]]) throws -> [[ClosedRange<ScalarAddress>]]
    {
        let ranges:[[ClosedRange<ScalarAddress>]] = try namespaces.map
        {
            try $0.map { try self.allocate(scalars: $0.scalars) }
        }
        for ((culture, ranges), sources):
            (
                (Int, [ClosedRange<ScalarAddress>]),
                [Compiler.Namespace]
            )
            in zip(zip(ranges.indices, ranges), namespaces)
        {
            let namespaces:[SymbolGraph.Namespace] = zip(ranges, sources).map
            {
                .init(range: $0.0, index: self.intern($0.1.id))
            }
            //  Record address ranges
            self.docs.graph.cultures[culture].namespaces = namespaces

            for (namespace, source):(SymbolGraph.Namespace, Compiler.Namespace)
                in zip(namespaces, sources)
            {
                let qualifier:ModuleIdentifier = self.docs.graph.namespaces[namespace.index]
                for (address, scalar) in zip(namespace.range, source.scalars)
                {
                    //  Make the scalar visible to codelink resolution.
                    self.resolver.overload(qualifier / scalar.path, with: .init(
                        target: .scalar(address),
                        phylum: scalar.phylum,
                        id: scalar.id))
                }
            }
        }
        return ranges
    }
    /// Allocates addresses for the given array of compiled extensions.
    /// This function also exposes any features conceived by the extensions for
    /// codelink resolution.
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
            let namespace:Int = self.intern($0.1.signature.extended.namespace)
            let qualifier:ModuleIdentifier = self.docs.graph.namespaces[namespace]

            //  Sort *then* address, since we want deterministic addresses too.
            let conformances:[ScalarAddress] = try self.addresses(
                of: $0.1.conformances.sorted())
            let features:[ScalarAddress] = try self.addresses(
                exposing: $0.1.features.sorted(),
                prefixed: (qualifier, $0.1.path),
                of: $0.1.extended.type,
                at: $0.0)
            let nested:[ScalarAddress] = try self.addresses(
                of: $0.1.nested.sorted())

            let index:Int = self.docs.graph.nodes[$0.0].push(.init(
                conditions: try $0.1.conditions.map
                {
                    try $0.map
                    {
                        try self.intern($0)
                    }
                },
                namespace: namespace,
                culture: $0.1.signature.culture,
                conformances: conformances,
                features: features,
                nested: nested))
            return ($0.0, index)
        }
    }
}
extension StaticLinker
{
    public mutating
    func link(namespaces:[[Compiler.Namespace]],
        at addresses:[[ClosedRange<ScalarAddress>]]) throws
    {
        for (namespaces, addresses):([Compiler.Namespace], [ClosedRange<ScalarAddress>])
            in zip(namespaces, addresses)
        {
            for (namespace, addresses) in zip(namespaces, addresses)
            {
                try self.link(scalars: namespace.scalars, at: addresses)
            }
        }
    }
    public mutating
    func link(scalars:[Compiler.Scalar], at addresses:ClosedRange<ScalarAddress>) throws
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
            let article:MarkdownArticle? = scalar.documentation.map
            {
                var outliner:Outliner = .init(resolver: self.resolver, scope: $0.scope)
                return outliner.link(comment: $0.comment)
            }

            {
                $0?.declaration = declaration

                $0?.superforms = superforms
                $0?.features = features
                $0?.origin = origin

                $0?.location = location
                $0?.article = article
            } (&self.docs.graph.nodes[address].scalar)
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
                self.docs.graph.nodes[address].extensions[index].article =
                    outliner.link(comment: comment)
            }
        }
    }
}
