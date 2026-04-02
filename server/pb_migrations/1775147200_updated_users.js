/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // add field
  collection.fields.addAt(17, new Field({
    "hidden": false,
    "id": "bool1042593233",
    "name": "high_contrast",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(18, new Field({
    "hidden": false,
    "id": "bool999834561",
    "name": "large_text",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(19, new Field({
    "hidden": false,
    "id": "bool2690250767",
    "name": "reduced_animations",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // add field
  collection.fields.addAt(20, new Field({
    "hidden": false,
    "id": "bool2239496990",
    "name": "screen_reader_opt",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("_pb_users_auth_")

  // remove field
  collection.fields.removeById("bool1042593233")

  // remove field
  collection.fields.removeById("bool999834561")

  // remove field
  collection.fields.removeById("bool2690250767")

  // remove field
  collection.fields.removeById("bool2239496990")

  return app.save(collection)
})
