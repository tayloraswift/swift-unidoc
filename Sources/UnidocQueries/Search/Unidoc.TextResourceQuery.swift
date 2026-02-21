
import BSON
import MD5
import MongoDB
import MongoQL
import UnidocDB
import UnidocRecords

extension Unidoc {
    /// A query that can avoid fetching the resource’s data if the hash matches.
    @frozen public struct TextResourceQuery<CollectionOrigin>: Equatable, Hashable, Sendable
        where CollectionOrigin: Mongo.CollectionModel {
        public let tag: MD5?
        public let id: CollectionOrigin.Element.ID

        @inlinable public init(tag: MD5?, id: CollectionOrigin.Element.ID) {
            self.tag = tag
            self.id = id
        }
    }
}
extension Unidoc.TextResourceQuery: Mongo.PipelineQuery {
    public typealias Iteration = Mongo.Single<Unidoc.TextResourceOutput>

    @inlinable public var collation: Mongo.Collation { .casefolding }
    @inlinable public var from: Mongo.Collection? { CollectionOrigin.name }
    @inlinable public var hint: Mongo.CollectionIndex? { nil }

    public func build(pipeline: inout Mongo.PipelineEncoder) {
        typealias Document = Unidoc.TextResource<CollectionOrigin.Element.ID>

        pipeline[stage: .match] {
            $0[Document[.id]] = self.id
        }

        pipeline[stage: .set, using: Unidoc.TextResourceOutput.CodingKey.self] {
            $0[.hash] = Document[.hash]
            $0[.text] {
                if  let tag: MD5 = self.tag {
                    $0[.cond] {
                        $0[.if] { $0[.eq] = (tag, Document[.hash]) }
                        $0[.then] {
                            $0[.binarySize] {
                                $0[.coalesce] = (Document[.gzip], Document[.utf8])
                            }
                        }
                        $0[.else] {
                            $0[.coalesce] = (Document[.gzip], Document[.utf8])
                        }
                    }
                } else {
                    $0[.coalesce] = (Document[.gzip], Document[.utf8])
                }
            }
        }
    }
}
