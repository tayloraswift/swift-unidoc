import BSON
import SymbolGraphs
import SymbolGraphTesting
import Symbols
import SystemIO
import Testing

@Suite
struct Precompiled
{
    private
    var directory:FilePath.Directory { "TestPackages" }

    @Test
    func swift_atomics() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "swift-atomics",
            in: self.directory)

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()
    }

    @Test
    func swift_nio() throws
    {
        //  https://github.com/tayloraswift/swift-unidoc/issues/211
        #if !os(macOS)

        let object:SymbolGraphObject<Void> = try .load(package: "swift-nio",
            in: self.directory)

        let dependencies:Set<Symbol.Package> = object.metadata.dependencies.reduce(into: [])
        {
            $0.insert($1.package.name)
        }

        //  the swift-docc-plugin dependency should have been linted.
        //  swift-nio grew a dependency on swift-system in 2.63.0
        #expect(dependencies == ["swift-atomics", "swift-collections", "swift-system"])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()

        #endif
    }

    @Test
    func swift_nio_ssl() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "swift-nio-ssl",
            in: self.directory)

        let dependencies:Set<Symbol.Package> = object.metadata.dependencies.reduce(into: [])
        {
            $0.insert($1.package.name)
        }

        #expect(dependencies == ["swift-atomics", "swift-collections", "swift-nio"])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()
    }

    //  The swift-async-dns-resolver repo includes a git submodule, so we should be able
    //  to handle that.
    @Test
    func swift_async_dns_resolver() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "swift-async-dns-resolver",
            in: self.directory)

        let dependencies:Set<Symbol.Package> = object.metadata.dependencies.reduce(into: [])
        {
            $0.insert($1.package.name)
        }

        #expect(dependencies == ["swift-atomics", "swift-collections", "swift-nio"])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()
    }

    //  SwiftSyntax is a morbidly obese package. If we can handle SwiftSyntax,
    //  we can handle anything!
    @Test
    func swift_syntax() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "swift-syntax",
            in: self.directory)

        //  the swift-argument-parser dependency should have been linted.
        #expect(object.metadata.dependencies == [])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()
    }

    @Test
    func indexstore_db() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "indexstore-db",
            in: self.directory)

        #expect(object.metadata.dependencies == [])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.decls.nodes.count > 0)

        try object.roundtrip()
    }

    @Test
    func swift_book() throws
    {
        let object:SymbolGraphObject<Void> = try .load(package: "swift-book",
            in: self.directory)

        #expect(object.metadata.dependencies == [])

        #expect(object.graph.cultures.count > 0)
        #expect(object.graph.articles.nodes.count > 0)
        #expect(object.graph.decls.nodes.count == 0)

        try object.roundtrip()
    }
}
