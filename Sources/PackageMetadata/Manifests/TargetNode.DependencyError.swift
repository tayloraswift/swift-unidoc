import PackageGraphs
import Symbols

extension TargetNode {
    @frozen public enum DependencyError: Error {
        case undefinedNominal(String)
        case undefinedProduct(Symbol.Product)
    }
}
