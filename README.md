## HackySerializer
Protocol-based serialization which works with any Swift type

## Motivation
This library was developed for the need of simple non-intrusive way to serialize any value to JSON which does not require manual work or subclassing.

## Usage
1. Specify conformance to `HackySerializable` protocol.
2. Access `.serialized` property of your value. This property has type `AnyObject` and contains either `Dictionary` or `Array` depending on the type of your value.
3. Convert to JSON if needed using `NSJSONSerialization`: 
```swift
let serialized = someStuff.serialized

let jsonData = try! NSJSONSerialization.dataWithJSONObject(serialized, options: [.PrettyPrinted])
let string = String(data: jsonData, encoding: NSUTF8StringEncoding)!

print(string)
```

## Example
```swift
enum SomeEnum {
  case Case1, Case2
}

class SomeStuff {
  let ok: String?
  let omg: String?
  let stuff: [Int?]
  
  init(ok: String?, omg: String?, stuff: [Int?]) {
    self.ok = ok
    self.omg = omg
    self.stuff = stuff
  }
}

struct Person: HackySerializable {
  let firstName: String
  let secondName: String
  let thingies: [SomeStuff]
  let idSet: Set<Int>
  let age: Int?
  let age2: Int?
  let someDict: [String: AnyObject?]
  
  let anotherThingy: SomeStuff
  
  let someEnumField: SomeEnum? = .Case1
  let anotherEnumField: SomeEnum = .Case2
}

let person = Person(
  firstName: "John",
  secondName: "Doe",
  thingies: [SomeStuff(ok: "111", omg: nil, stuff: [1, nil]), SomeStuff(ok: "222", omg: "22", stuff: [42, 100500])],
  idSet: [1, 2],
  age: 29,
  age2: nil,
  someDict: [ "hello": "world", "key": nil ],
  anotherThingy: SomeStuff(ok: "ok", omg: nil, stuff: [])
)
```
Resulting JSON:
```JSON
{
  "age2" : null,
  "anotherEnumField" : "Case2",
  "secondName" : "Doe",
  "someEnumField" : "Case1",
  "thingies" : [
    {
      "stuff" : [
        1,
        null
      ],
      "ok" : "111",
      "omg" : null
    },
    {
      "stuff" : [
        42,
        100500
      ],
      "ok" : "222",
      "omg" : "22"
    }
  ],
  "someDict" : {
    "hello" : "world",
    "key" : null
  },
  "age" : 29,
  "firstName" : "John",
  "anotherThingy" : {
    "stuff" : [

    ],
    "ok" : "ok",
    "omg" : null
  },
  "idSet" : [
    2,
    1
  ]
}
```
Note that `SomeEnum` and `SomeStuff` do not need to conform to `HackySerializable`


## Limitations
1. Performance: This library relies on reflection, so use carefully or face performance penalties.
2. Superclass serialization: not implemented (yet).
3. Dictionary keys must be `String`s (more generic `Hashable` keys are not yet supported).
4. Enums: current implementation just uses the enum case name. Raw values are not supported due to the limitations of Swift reflection, associated values might be supported later.

## Feedback
This project is in its very early stage. If you have an idea or found an issue, submit it here or write me on Twitter ([@andrii_ch](https://twitter.com/andrii_ch))


