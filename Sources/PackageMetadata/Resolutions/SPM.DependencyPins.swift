import Symbols

extension SPM {
    /// An index of identifiable digraph nodes.
    @frozen public struct DependencyPins {
        @usableFromInline internal var index: [Symbol.Package: DependencyPin]

        @inlinable internal init(index: [Symbol.Package: DependencyPin] = [:]) {
            self.index = index
        }
    }
}
extension SPM.DependencyPins {
    public init(indexing pins: [SPM.DependencyPin]) throws {
        self.init()

        for pin: SPM.DependencyPin in pins {
            if  case _? = self.index.updateValue(pin, forKey: pin.identity) {
                throw SPM.DependencyPinError.duplicate(pin.identity)
            }
        }
    }
}
extension SPM.DependencyPins {
    @inlinable public func callAsFunction(
        _ identity: Symbol.Package
    ) throws -> SPM.DependencyPin {
        if  let pin: SPM.DependencyPin = self.index[identity] {
            return pin
        } else {
            throw SPM.DependencyPinError.undefined(identity)
        }
    }
}
