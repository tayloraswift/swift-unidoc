extension TaskGroup<Void>
{
    mutating
    func iterate<Inbound>(_ inbound:Inbound,
        width:Int,
        with body:@Sendable @escaping (Inbound.Element) async -> (),
        else handle:(any Error) -> ()) async
        where Inbound:AsyncSequence, Inbound.Element:Sendable
    {
        var iterator:Inbound.AsyncIterator = inbound.makeAsyncIterator()

        do
        {
            for _:Int in 0 ..< width
            {
                guard
                let element:Inbound.Element = try await iterator.next()
                else
                {
                    return
                }

                self.addTask { await body(element) }
            }

            for try await _:Void in self
            {
                guard
                let element:Inbound.Element = try await iterator.next()
                else
                {
                    return
                }

                self.addTask { await body(element) }
            }
        }
        catch let error
        {
            handle(error)
        }
    }
}
