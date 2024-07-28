import _AsyncChannel

extension AsyncSequence where Element:Sendable
{
    consuming
    func forward<T>(to channel:AsyncThrowingChannel<T, any Error>,
        by transform:(Element) throws -> T) async rethrows
    {
        do
        {
            for try await element:Element in self
            {
                await channel.send(try transform(element))
            }

            channel.finish()
        }
        catch let error
        {
            channel.fail(error)
        }
    }

    consuming
    func forward<T>(to stream:AsyncThrowingStream<T, any Error>.Continuation,
        by transform:(Element) throws -> T) async rethrows
    {
        do
        {
            for try await element:Element in self
            {
                stream.yield(try transform(element))
            }

            stream.finish()
        }
        catch let error
        {
            stream.finish(throwing: error)
        }
    }

    @inlinable consuming
    func iterate(concurrently width:Int,
        with body:@Sendable @escaping (Element) async -> ()) async throws
    {
        var iterator:AsyncIterator = self.makeAsyncIterator()
        let exit:Result<Void, any Error> = await withTaskGroup(of: Void.self)
        {
            (tasks:inout TaskGroup<Void>) in

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
