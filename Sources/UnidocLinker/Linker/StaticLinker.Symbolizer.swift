import CodelinkResolution
import ModuleGraphs
import SymbolGraphs
import Symbols
import UnidocCompiler

extension StaticLinker
{
    struct Symbolizer
    {
        /// Interned module names. This only contains modules that
        /// are not included in the symbol graph being linked.
        private
        var modules:[ModuleIdentifier: Int]
        private
        var scalars:[ScalarSymbol: Int32]
        private
        var files:[FileSymbol: Int32]

        var graph:SymbolGraph

        init(modules:[ModuleDetails])
        {
            self.modules = [:]
            self.scalars = [:]
            self.files = [:]

            self.graph = .init(modules: modules)
        }
    }
}
extension StaticLinker.Symbolizer
{
    /// Indexes the given scalar and appends it to the symbol graph.
    ///
    /// This function only populates basic information (flags and path)
    /// about the scalar, the rest should only be added after completing
    /// a full pass over all the scalars and extensions.
    ///
    /// This function doesn’t check for duplicates.
    mutating
    func allocate(scalar:Compiler.Scalar) -> Int32
    {
        let address:Int32 = self.graph.append(.init(phylum: scalar.phylum,
                aperture: scalar.aperture,
                path: scalar.path),
            id: scalar.id)

        self.scalars[scalar.id] = address
        return address
    }
    /// Indexes the scalar extended by the given extension and appends
    /// the (empty) scalar to the symbol graph, if it has not already
    /// been indexed. (This function checks for duplicates.)
    mutating
    func allocate(extension:Compiler.Extension) -> Int32
    {
        let scalar:ScalarSymbol = `extension`.extended.type
        let address:Int32 =
        {
            switch $0
            {
            case nil:
                let address:Int32 = self.graph.append(nil, id: scalar)
                $0 = address
                return address

            case let address?:
                return address
            }
        } (&self.scalars[scalar])
        return address
    }
}
extension StaticLinker.Symbolizer
{
    /// Returns the address of the file with the given identifier,
    /// registering it in the symbol table if needed.
    mutating
    func intern(_ id:FileSymbol) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let address:Int32 = self.graph.files.append(id)
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
    mutating
    func intern(_ id:ScalarSymbol) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let address:Int32 = self.graph.symbols.append(id)
                $0 = address
                return address

            case let address?:
                return address
            }
        } (&self.scalars[id])
    }

    mutating
    func intern(_ id:ModuleIdentifier) -> Int
    {
        {
            switch $0
            {
            case nil:
                let index:Int = self.graph.append(namespace: id)
                $0 = index
                return index

            case let index?:
                return index
            }
        } (&self.modules[id])
    }
    mutating
    func intern(_ id:Compiler.Namespace.ID) -> Int
    {
        switch id
        {
        case .index(let culture):   return culture
        case .nominated(let id):    return self.intern(id)
        }
    }
}
extension StaticLinker.Symbolizer
{
    func excerpt(for overload:CodelinkResolver<Int32>.Overload) -> StaticLinker.Excerpt
    {
        let scalar:Int32
        switch overload.target
        {
        case .scalar(let address):
            scalar = address

        case .vector(let address, self: _):
            scalar = address
        }

        let symbol:ScalarSymbol = self.graph.symbols[scalar]
        if  let scalar:SymbolGraph.Scalar = self.graph[scalar]?.scalar
        {
            return .init(symbol: symbol, fragments: scalar.declaration.expanded.bytecode)
        }
        else
        {
            return .init(symbol: symbol, fragments: nil)
        }
    }
}
