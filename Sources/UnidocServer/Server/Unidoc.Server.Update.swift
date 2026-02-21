import HTTP

extension Unidoc.Server {
    struct Update: Sendable {
        let operation: any Unidoc.ProceduralOperation
        let payload: [UInt8]
        let promise: Promise

        init(
            operation: any Unidoc.ProceduralOperation,
            payload: [UInt8] = [],
            promise: Promise
        ) {
            self.operation = operation
            self.payload = payload
            self.promise = promise
        }
    }
}
