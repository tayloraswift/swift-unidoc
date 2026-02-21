extension AWS.S3 {
    public enum RequestError: Error, Equatable, Sendable {
        case get    (UInt, String)
        case put    (UInt, String)
        case delete (UInt, String)
    }
}
