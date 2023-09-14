# mongo_one

## 0.2.0 Updates 
- Removed `auto_map` - auto maps by default.
- `map_to` doesn't execute query anymore, it just sets mapping class and returns the query.
- Added new methods that execute query: `one`, `one!` and `all`. `one!` raises `MongoOne::Errors:NotFound` if no document found.
- Container friendly. `Collection.new.find()`
- AST Support for Types::Any. Use `Types::Any` for `_id` in your Dry::Structs if you want to get `_id` as `BSON::ObjectId`. 
- Auto Mapped struct now has `_id` as `Types::Any` by default.
- Added missing keys toleration in `schema`. Use `attribute?` if the field in the db document is optional.