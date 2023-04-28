import CodelinkResolution
import Declarations
import Generics
import MarkdownABI
import MarkdownParsing
import MarkdownSemantics
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
        of extended:Symbol.Scalar,
        at address:ScalarAddress) throws -> [ScalarAddress]
    {
        if  let prefix:[String] =
            self.graph.scalars[address]?.path.map({ $0 }) ??
            self.external[heir: extended]
        {
            return try features.map
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
        else
        {
            return try self.addresses(of: features)
        }
    }
}
extension Linker
{
    private mutating
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
    private mutating
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

    init(metadata:SymbolGraph.Metadata,
        context:Compiler.Scalars.External,
        scalars:[Compiler.Scalar],
        extensions:[Compiler.Extension]) throws
    {
        self.init(metadata: metadata, context: context)

        let scalarAddresses:[ScalarAddress] = try self.register(
            scalars: scalars)
        let extensionAddresses:[(ScalarAddress, Int)] = try self.register(
            extensions: extensions)

        try self.link(scalars: scalars, at: scalarAddresses)
        try self.link(extensions: extensions, at: extensionAddresses)
    }
}
extension Linker
{
    mutating
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

            let article:SymbolGraph.Article<SymbolGraph.Referent>? = self.link(
                comment: scalar.comment,
                for: address)

            self.graph.scalars[address]?.declaration = declaration
            self.graph.scalars[address]?.location = location
            self.graph.scalars[address]?.article = article
        }
    }
    mutating
    func link(extensions:[Compiler.Extension], at addresses:[(ScalarAddress, Int)]) throws
    {
        for ((address, index), _):((ScalarAddress, Int), Compiler.Extension)
            in zip(addresses, extensions)
        {
            { _ in }(&self.graph.scalars[address, index])
        }
    }
}
extension Linker
{
    private
    func link(comment:String,
        for address:ScalarAddress) -> SymbolGraph.Article<SymbolGraph.Referent>?
    {
        if  comment.isEmpty
        {
            return nil
        }

        //  If the comment is attached to an extension of an external type,
        //  it can only use “absolute” codelinks.
        let scope:[String] = self.graph.scalars[address].map
        {
            switch $0.phylum
            {
            case    .actor,
                    .class,
                    .enum,
                    .protocol,
                    .struct:
                return $0.path.map { $0 }
            
            case    .associatedtype,
                    .case,
                    .deinitializer,
                    .func,
                    .initializer,
                    .operator,
                    .subscript,
                    .typealias,
                    .var:
                return $0.path.prefix
            }
        } ?? []

        let documentation:MarkdownDocumentation = .init(parsing: comment,
            as: SwiftFlavoredMarkdown.self)

        var references:[Codelink: UInt32] = [:]
        var referents:[SymbolGraph.Referent] = []
        var fold:Int = referents.endIndex
        
        documentation.visit
        {
            if  $0 is MarkdownDocumentation.Fold
            {
                fold = referents.endIndex
                return
            }

            $0.outline
            {
                (expression:String) -> UInt32? in

                guard let codelink:Codelink = .init(parsing: expression)
                else
                {
                    print("invalid codelink '\(expression)'")
                    return nil
                }

                let reference:UInt32? =
                {
                    if  let reference:UInt32 = $0
                    {
                        return reference
                    }

                    let referent:SymbolGraph.Referent
                    switch self.resolver.query(ascending: scope, link: codelink)
                    {
                    case nil:
                        referent = .unresolved(codelink)
                    
                    case .one(let overload)?:
                        switch overload.target
                        {
                        case .scalar(let address):
                            referent = .scalar(address)
                        
                        case .vector(let address, self: let heir):
                            referent = .vector(address, self: heir)
                        }
                    
                    case .many?:
                        print("ambiguous codelink '\(codelink)'")
                        return nil
                    }

                    let next:UInt32 = .init(referents.endIndex)
                    referents.append(referent)
                    $0 = next
                    return next

                } (&references[codelink])

                return reference
            }
        }

        let binary:MarkdownBinary = .init(from: documentation)
        return .init(markdown: binary.bytes, links: referents, fold: fold)
    }
}
