import CodelinkResolution
import ModuleGraphs
import SymbolGraphCompiler
import SymbolGraphs
import Symbols

extension StaticLinker
{
    struct Symbolizer
    {
        /// Interned module names. This only contains modules that
        /// are not included in the symbol graph being linked.
        private
        var modules:[ModuleIdentifier: Int]
        private
        var decls:[Symbol.Decl: Int32]
        private
        var files:[Symbol.File: Int32]

        var graph:SymbolGraph

        init(modules:[ModuleDetails])
        {
            self.modules = [:]
            self.decls = [:]
            self.files = [:]

            self.graph = .init(modules: modules)
        }
    }
}
extension StaticLinker.Symbolizer
{
    /// Indexes the given declaration and appends it to the symbol graph.
    ///
    /// This function only populates basic information (flags and path)
    /// about the declaration, the rest should only be added after completing
    /// a full pass over all the declarations and extensions.
    ///
    /// This function doesn’t check for duplicates.
    mutating
    func allocate(decl:Compiler.Decl) -> Int32
    {
        let scalar:Int32 = self.graph.append(.init(
                customization: decl.customization,
                phylum: decl.phylum,
                path: decl.path),
            id: decl.id)

        self.decls[decl.id] = scalar
        return scalar
    }
    /// Indexes the declaration extended by the given extension and appends
    /// the (empty) declaration to the symbol graph, if it has not already
    /// been indexed. (This function checks for duplicates.)
    mutating
    func allocate(extension:Compiler.Extension) -> Int32
    {
        let decl:Symbol.Decl = `extension`.extended.type
        let scalar:Int32 =
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.append(nil, id: decl)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[decl])
        return scalar
    }
}
extension StaticLinker.Symbolizer
{
    /// Returns the scalar for the given declaration symbol,
    /// registering it in the symbol table if needed. You should never
    /// call ``allocate(decl:)`` or ``allocate(extension:)`` after
    /// calling this function.
    mutating
    func intern(_ id:Symbol.Decl) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.decls.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.decls[id])
    }

    /// Returns the scalar for the given file symbol,
    /// registering it in the symbol table if needed.
    mutating
    func intern(_ id:Symbol.File) -> Int32
    {
        {
            switch $0
            {
            case nil:
                let scalar:Int32 = self.graph.files.append(id)
                $0 = scalar
                return scalar

            case let scalar?:
                return scalar
            }
        } (&self.files[id])
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
