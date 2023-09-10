// import BSONDecoding
// import BSONEncoding
// import GitHubIntegration
// import MongoQL

// extension GitHubAPI.Repo:MongoMasterCodingModel
// {
// }
// extension GitHubAPI.Repo:BSONDocumentEncodable
// {
//     public
//     func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
//     {
//         bson[.id] = self.id
//         bson[.owner] = self.owner
//         bson[.name] = self.name
//         bson[.node] = self.node
//         bson[.license] = self.license
//         bson[.topics] = self.topics.isEmpty ? nil : self.topics
//         bson[.master] = self.master
//         bson[.watchers] = self.watchers
//         bson[.forks] = self.forks
//         bson[.stars] = self.stars
//         bson[.size] = self.size
//         bson[.archived] = self.archived
//         bson[.disabled] = self.disabled
//         bson[.fork] = self.fork
//         bson[.homepage] = self.homepage
//         bson[.about] = self.about
//         bson[.created] = self.created
//         bson[.updated] = self.updated
//         bson[.pushed] = self.pushed
//     }
// }
// extension GitHubAPI.Repo:BSONDocumentDecodable
// {
//     @inlinable public
//     init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
//     {
//         self.init(id: try bson[.id].decode(),
//             owner: try bson[.owner].decode(),
//             name: try bson[.name].decode(),
//             node: try bson[.node].decode(),
//             license: try bson[.license]?.decode(),
//             topics: try bson[.topics]?.decode() ?? [],
//             master: try bson[.master].decode(),
//             watchers: try bson[.watchers].decode(),
//             forks: try bson[.forks].decode(),
//             stars: try bson[.stars].decode(),
//             size: try bson[.size].decode(),
//             archived: try bson[.archived].decode(),
//             disabled: try bson[.disabled].decode(),
//             fork: try bson[.fork].decode(),
//             homepage: try bson[.homepage]?.decode(),
//             about: try bson[.about]?.decode(),
//             created: try bson[.created].decode(),
//             updated: try bson[.updated].decode(),
//             pushed: try bson[.pushed].decode())
//     }
// }
