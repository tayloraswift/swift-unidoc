import Atomics

extension AtomicPointer
{
    @usableFromInline final
    class Storage:AtomicReference, Sendable
    {
        @usableFromInline
        let value:Value

        @inlinable internal
        init(_ value:Value)
        {
            self.value = value
        }
    }
}
