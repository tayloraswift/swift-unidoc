import Signatures

@frozen public struct SignatureLandmarks {
    public var keywords: InterestingKeywords
    public var inputs: [String]
    public var output: [String]

    @inlinable public init() {
        self.keywords = .init()
        self.inputs = []
        self.output = []
    }
}
