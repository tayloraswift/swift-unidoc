extension SSGC {
    @frozen public enum DocumentationBuildError: Error {
        case scanning(any Error)
        case loading(any Error)
        case linking(any Error)
    }
}
extension SSGC.DocumentationBuildError {
    @inlinable public var underlying: any Error {
        switch self {
        case .scanning(let error):  error
        case .loading(let error):   error
        case .linking(let error):   error
        }
    }
}
