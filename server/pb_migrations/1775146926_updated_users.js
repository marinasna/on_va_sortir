/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update field
  collection.fields.addAt(17, new Field({
    "hidden": false,
    "id": "select3367241194",
    "maxSelect": 6,
    "name": "interests",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Gaming",
      "Sport",
      "Food",
      "Soirées",
      "Nature",
      "Culture"
    ]
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // update field
  collection.fields.addAt(17, new Field({
    "hidden": false,
    "id": "select3367241194",
    "maxSelect": 2,
    "name": "interests",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "select",
    "values": [
      "Gaming",
      "Sport",
      "Food",
      "Soirées",
      "Nature",
      "Culture"
    ]
  }))

  return app.save(collection)
})
