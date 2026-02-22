extension Unidoc {
    @frozen public struct LinkReference<Vertex> {
        public let vertex: Vertex
        /// Nil if the link target could not be computed.
        ///
        /// In exceptional cases, it is possible to successfully load the vertex record but fail
        /// to compute its location, for example, due to missing volume metadata.
        public var target: LinkTarget?

        @inlinable public init(vertex: Vertex, target: LinkTarget? = nil) {
            self.vertex = vertex
            self.target = target
        }
    }
}
