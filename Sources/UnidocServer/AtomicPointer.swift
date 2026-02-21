import Atomics

@frozen public struct AtomicPointer<Value>: Sendable where Value: Sendable {
    @usableFromInline let pointer: ManagedAtomic<Storage?>

    @inlinable public init() {
        self.pointer = .init(nil)
    }

    @inlinable public func load() -> Value? {
        self.pointer.load(ordering: .relaxed)?.value
    }

    @inlinable public func clear() {
        self.pointer.store(nil, ordering: .relaxed)
    }

    @inlinable public func replace(value: Value) {
        self.pointer.store(.init(value), ordering: .relaxed)
    }
}
