import SymbolGraphCompiler
import Symbols
import Testing_

extension Main {
    enum ExternalExtensionsWithConstraints {
    }
}
extension Main.ExternalExtensionsWithConstraints: CompilerTestBattery {
    static let inputs: [Symbol.Module] = [
        "ExtendableTypesWithConstraints",
        "ExternalExtensionsWithConstraints",
    ]

    static func run(tests: TestGroup, module: SSGC.ModuleIndex) {
    }
}
