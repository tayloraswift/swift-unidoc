extension AsyncSequence where Element:Sendable
{
    @inlinable internal consuming
    func iterate(concurrently width:Int,
        with body:@Sendable @escaping (Element) async -> ()) async throws
    {
        let exit:Result<Void, any Error> = await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

            var iterator:AsyncIterator = self.makeAsyncIterator()

            do
            {
                for _:Int in 0 ..< width
                {
                    guard
                    let element:Element = try await iterator.next()
                    else
                    {
                        return .success(())
                    }

                    tasks.addTask { await body(element) }
                }

                for await _:Void in tasks
                {
                    guard
                    let element:Element = try await iterator.next()
                    else
                    {
                        return .success(())
                    }

                    tasks.addTask { await body(element) }
                }

                return .success(())
            }
            catch let error
            {
                return .failure(error)
            }
        }

        try exit.get()
    }
}
