import Atomics

extension Unidoc.BuildCoordinator
{
    final
    class Subscription:Sendable
    {
        let assignee:Unidoc.Account

        private
        let consumer:CheckedContinuation<Unidoc.BuildLabels, any Error>
        private
        let consumerAwaiting:ManagedAtomic<Bool>

        init(assignee:Unidoc.Account,
            consumer:CheckedContinuation<Unidoc.BuildLabels, any Error>)
        {
            self.assignee = assignee
            self.consumer = consumer
            self.consumerAwaiting = .init(true)
        }

        func resume(returning labels:__owned Unidoc.BuildLabels) -> Unidoc.BuildLabels?
        {
            if  self.consumerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.consumer.resume(returning: labels)
                return nil
            }
            else
            {
                return labels
            }
        }

        func cancel()
        {
            if  self.consumerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.consumer.resume(throwing: CancellationError.init())
            }
        }

        deinit
        {
            if  self.consumerAwaiting.exchange(false, ordering: .relaxed)
            {
                self.consumer.resume(
                    throwing: Unidoc.BuildCoordinatorAssertionError.droppedSubscription)
            }
        }
    }
}
