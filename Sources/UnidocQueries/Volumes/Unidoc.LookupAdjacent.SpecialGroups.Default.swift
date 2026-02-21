import MongoQL
import UnidocRecords

extension Unidoc.LookupAdjacent.SpecialGroups {
    struct Default {
        let peers: Mongo.Variable<Unidoc.Group>
        let topic: Mongo.Variable<Unidoc.Group>

        init(
            peers: Mongo.Variable<Unidoc.Group>,
            topic: Mongo.Variable<Unidoc.Group>
        ) {
            self.peers = peers
            self.topic = topic
        }
    }
}
