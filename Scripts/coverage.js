db = connect('mongodb://apex.swiftinit.org:1000/unidoc');

var aggregate = {
    aggregate: 'SearchbotGrid',
    pipeline: [
        {
            $match: {
                '_id.P': { $lt: 100 }
            }
        },
        {
            $group: {
                _id: '$_id.P',
                googlebot: { $sum: '$G' },
                googlebot_unique: {
                    $sum: { $min: [{ $ifNull: ['$G', 0] }, 1] }
                },
                bingbot: { $sum: '$M' },
                bingbot_unique: {
                    $sum: { $min: [{ $ifNull: ['$M', 0] }, 1] }
                },
                yandexbot: { $sum: '$Y' },
                yandexbot_unique: {
                    $sum: { $min: [{ $ifNull: ['$Y', 0] }, 1] }
                },
            }
        },
        {
            $sort: { _id: 1 }
        }
    ],
    cursor: { batchSize: 10 }
}

console.log(db.runCommand(aggregate));
