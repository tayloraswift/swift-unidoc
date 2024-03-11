db = connect('mongodb://apex.swiftinit.org:1000/unidoc');

var aggregate = {
    aggregate: 'Snapshots',
    pipeline: [
        {
            $match: {}
        },
        {
            $group: {
                _id: '$M.abi',
                count: { $sum: 1 },
                sizeS3: { $sum: '$B' },
                sizeInline: { $sum: { $bsonSize: '$D' } }
            }
        },
        {
            $sort: { _id: 1 }
        }
    ],
    cursor: { batchSize: 200 }
}

console.log(db.runCommand(aggregate));
