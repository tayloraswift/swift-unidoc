// import HTTPServer
// import System

// struct CacheTable<Key> where Key:CacheKey
// {
//     private
//     var resources:[Key: ServerResource]

//     init(resources:[Key: ServerResource])
//     {
//         self.resources = resources
//     }
// }
// extension CacheTable:ExpressibleByDictionaryLiteral
// {
//     init(dictionaryLiteral elements: (Key, Never)...)
//     {
//         self.init(resources: [:])
//     }
// }
