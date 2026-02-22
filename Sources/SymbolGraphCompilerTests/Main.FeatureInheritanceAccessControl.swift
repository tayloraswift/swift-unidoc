import SymbolGraphCompiler
@_spi(testable) import Symbols
import Testing_

extension Main {
    enum FeatureInheritanceAccessControl {
    }
}
extension Main.FeatureInheritanceAccessControl: CompilerTestBattery {
    static let inputs: [Symbol.Module] = [
        "FeatureInheritanceAccessControl",
    ]

    static func run(tests: TestGroup, module: SSGC.ModuleIndex) {
        let declsBySymbol: [Symbol.Decl: SSGC.Decl] = module.declarations.reduce(into: [:]) {
            for decl: SSGC.Decl in $1.decls {
                $0[decl.id] = decl
            }
        }
        let features: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.features
        }


        if  let tests: TestGroup = tests / "S",
            let _: SSGC.Decl = tests.expect(
                value: declsBySymbol["s31FeatureInheritanceAccessControl1SV"]
            ) {
            tests.expect(nil: features["s31FeatureInheritanceAccessControl1SV"])
        }
    }
}
