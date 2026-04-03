import SymbolGraphCompiler
@_spi(testable) import Symbols
import Testing

@Suite struct ModuleLoadingTests {
    @Test static func Determinism() throws {
        /// test loading the standard library from two separate symbol dumps
        let a: SSGC.ModuleIndex = try #require(try .load(from: "TestModules/SymbolGraphs"))
        let b: SSGC.ModuleIndex = try #require(try .load(from: "TestModules/Determinism"))

        #expect(a.extensions == b.extensions)

        for (a, b): (
                (id: Symbol.Module, decls: [SSGC.Decl]),
                (id: Symbol.Module, decls: [SSGC.Decl])
            ) in zip(a.declarations, b.declarations) {
            #expect(a.id == b.id)
            #expect(a.decls == b.decls)
        }
    }

    @Test static func ExternalExtensionsWithConformances() throws {
        let module: SSGC.ModuleIndex = try .load(
            inputs: ["ExtendableTypesWithConstraints", "ExternalExtensionsWithConformances"]
        )
        try module.testSourceLocations()
    }
    @Test static func ExternalExtensionsWithConstraints() throws {
        let module: SSGC.ModuleIndex = try .load(
            inputs: ["ExtendableTypesWithConstraints", "ExternalExtensionsWithConstraints"]
        )
        try module.testSourceLocations()
    }
    @Test static func InternalExtensionsWithConformances() throws {
        let module: SSGC.ModuleIndex = try .load(inputs: ["InternalExtensionsWithConformances"])
        try module.testSourceLocations()
    }
    @Test static func InternalExtensionsWithConstraints() throws {
        let module: SSGC.ModuleIndex = try .load(inputs: ["InternalExtensionsWithConstraints"])
        try module.testSourceLocations()
    }

    @Test static func FeatureInheritance() throws {
        let module: SSGC.ModuleIndex = try .load(inputs: ["FeatureInheritance"])
        try module.testSourceLocations()
        let features: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.features
        }

        let featuresOnRandomAccessType: [Symbol.Decl] = try #require(
            features["s18FeatureInheritance16RandomAccessTypeV"]
        )
        #expect(featuresOnRandomAccessType.contains("sSKsE6suffixy11SubSequenceQzSiF"))
    }
    @Test static func FeatureInheritanceAccessControl() throws {
        let module: SSGC.ModuleIndex = try .load(inputs: ["FeatureInheritanceAccessControl"])
        try module.testSourceLocations()
        let declsBySymbol: [Symbol.Decl: SSGC.Decl] = module.declarations.reduce(into: [:]) {
            for decl: SSGC.Decl in $1.decls {
                $0[decl.id] = decl
            }
        }
        let features: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.features
        }

        #expect(nil != declsBySymbol["s31FeatureInheritanceAccessControl1SV"])
        #expect(nil == features["s31FeatureInheritanceAccessControl1SV"])
    }

    // these are all one test case, to avoid reparsing the same module multiple times
    @Test static func DefaultImplementations() throws {
        let module: SSGC.ModuleIndex = try .load(inputs: ["DefaultImplementations"])
        try module.testSourceLocations()
        let features: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.features
        }
        let nested: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.nested
        }
        let decls: [Symbol.Decl: SSGC.Decl] = module.declarations.reduce(into: [:]) {
            for decl: SSGC.Decl in $1.decls {
                $0[decl.id] = decl
            }
        }

        // default implementation inheritance
        #expect(
            features["s22DefaultImplementations4EnumO"]?.sorted() == [
                "s22DefaultImplementations9ProtocolBPAAE1fyyF",
                "s22DefaultImplementations9ProtocolCPAAE2idSSvp",
            ],
        )

        // default implementation scopes
        #expect(
            nested["s22DefaultImplementations9ProtocolBP"]?.sorted() == [
                "s22DefaultImplementations9ProtocolBPAAE1fyyF",
            ],
        )

        //  This checks that we are stripping the inherited documentation comment
        let protocolB_f: SSGC.Decl? = decls["s22DefaultImplementations9ProtocolBPAAE1fyyF"]
        #expect(nil != protocolB_f)
        #expect(nil == protocolB_f?.comment)
    }
}
