db = connect('mongodb://swiftinit.org:27017/unidoc');

var migrateEditions = {
    aggregate: '_editions',
    pipeline: [
        {
            $match: {}
        },
        {
            $replaceWith: {
                _id: '$_id',
                p: '$P',
                v: '$V',
                R: '$R',
                A: '$A',
                T: '$T',
                S: '$S',
            }
        },
        {
            $out: {
                db: 'unidoc',
                coll: 'Editions',
            }
        },
    ],
    cursor: { batchSize: 100 }
}

var migratePackages = {
    aggregate: '_packages',
    pipeline: [
        {
            $match: {}
        },
        {
            $replaceWith: {
                _id: '$P',
                Y: '$_id',
                r: '$r',
                R: '$R',
                T: '$T',
            }
        },
        {
            $out: {
                db: 'unidoc',
                coll: 'Packages',
            }
        },
    ],
    cursor: { batchSize: 100 }
}

var migratePackageAliases = {
    aggregate: '_packages',
    pipeline: [
        {
            $match: {}
        },
        {
            $replaceWith: {
                _id: '$_id',
                p: '$P',
            }
        },
        {
            $out: {
                db: 'unidoc',
                coll: 'PackageAliases',
            }
        },
    ],
    cursor: { batchSize: 100 }
}

var migrateSnapshots = {
    aggregate: 'symbolgraphs',
    pipeline: [
        {
            $match: {}
        },
        {
            $lookup: {
                from: 'Editions',
                let: {
                    p: '$P',
                    v: '$V',
                },
                pipeline: [
                    {
                        $match: {
                            $expr: {
                                $and: [
                                    { $eq: ['$p', '$$p'] },
                                    { $eq: ['$v', '$$v'] },
                                ]
                            }
                        }
                    },
                    {
                        $project: {
                            _id: 1,
                        }
                    },
                ],
                as: '_id',
            }
        },
        {
            $unwind: '$_id',
        },
        {
            $replaceWith: {
                _id: '$_id._id',
                M: '$M',
                D: '$D',
            }
        },
        {
            $out: {
                db: 'unidoc',
                coll: 'Snapshots',
            }
        },
    ],
    cursor: { batchSize: 200 }
}

var migrateGroups = {
    update: 'VolumeGroups',
    updates: [
        {
            multi: true,
            q: {
                L: true
            },
            u: {
                $set: {
                    R: 0,
                },
                $unset: {
                    L: '',
                }
            }
        },
    ]
}


//  console.log(db.runCommand(migrateEditions));
//  console.log(db.runCommand(migratePackages));
//  console.log(db.runCommand(migratePackageAliases));
//  console.log(db.runCommand(migrateSnapshots));
console.log(db.runCommand(migrateGroups));
