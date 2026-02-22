import SymbolGraphCompiler
@_spi(testable) import Symbols
import Testing_

extension Main {
    enum FeatureInheritance {
    }
}
extension Main.FeatureInheritance: CompilerTestBattery {
    static let inputs: [Symbol.Module] = [
        "FeatureInheritance",
    ]

    static func run(tests: TestGroup, module: SSGC.ModuleIndex) {
        let features: [Symbol.Decl: [Symbol.Decl]] = module.extensions.reduce(into: [:]) {
            $0[$1.extendee.id, default: []] += $1.features
        }

        if  let tests: TestGroup = tests / "RandomAccessType",
            let features: [Symbol.Decl] = tests.expect(
                value: features["s18FeatureInheritance16RandomAccessTypeV"]
            ) {
            tests.expect(true: features.contains("sSKsE6suffixy11SubSequenceQzSiF"))
        }
    }
}
