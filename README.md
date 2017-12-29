# XMLWrangler

Easily deal with XMLs in Swift.

## Usage

### Element

Every element in an XML is represented by the `Element` struct. It has three properties, `name` which reflects the element's tag name, `attributes` which contains all attributes of the element as a Dictionary and `content` which describes the content of the element.
The content is an array of a `Content` enum. The enum has two cases: `.string` and `.objects`. The order in the array is the order in which the content has been found. So if an element first contains some text, then contains some child elements and finally again some text, the `content` array will contain a `.string` whose associated `String` is the first text. Next there would be a `.objects` whose associated `Array<Element>` contains all the objects. Finally, there would be another `.string` with the last text.

While you can create an `Element` with a content of `[.string("abc"), .string("def"), .objects(["test"]), .objects(["another_test"])]`, and it would also lead to valid XML, it could be cleaned up to `[.string("abcdef"), .objects(["test", "another_test"])]`. To achieve that, it's recommended to use the various `append` funcs when you can't assure that the content is cleaned upon creation. If your element was created with an empty content (`[]`), and you'd append each of the content elements above, the `append` funcs make sure that they append the "def" string to the first "abc" string instead of adding another `.string` to the content array.

An `Element` can be compared to another element and is considered equal if all three properties (`name`, `attributes` and `content`) are equal. This means that for a big tree, all children of the root element will be compared. So be careful when comparing big trees and fall back to manually comparing `name` and/or `attributes` if necessary.

Both, serializing and parsing XMLs with XMLWrangler relies on `Element`.

### Parsing XMLs

Parsing existing XMLs can be done using the `Parser` class. You can instantiate a parser with either a given `Data` object or a `String` containing the XML. The latter might return `nil` if the String can't be converted to a `Data` object.

Once you have a parser ready, you can call `parse()` on it, and it'll try to parse the XML. If that succeeds, it'll return the parsed root object. Otherwise it throws whatever error happend along the way. Errors thrown are the ones created by `Foundation.XMLParser`.

```swift
let xml = """
          <?xml version='1.0' encoding='UTF-8'?>
          <root myattr='myvalue'>
              <child1/>
              <child2>some text</child2>
          </root>
          """
guard let parser = Parser(string: xml)
    else { fatalError("Check your xml string. And please don't use `fatalError` ;)") }
do {
    let rootElement = try parser.parse()
} catch {
    print("Something went wrong while parsing: \(error)")
}
```

In this example, `root.name` would of course be `"root"`. `rootElement.content` would be an array containing one `.objects` and have two objects in its associated array. The first would have a `name` of `"child1"` and a `content` which is an empty array. The `name` of second one would be `"child2"` and its content would contain one `.string` with `"some text"` as associated String. `root.attributes` would contain the value `"myvalue"` for the key `"myattr"`.


### Serializing Elements

Since you can parse XMLs, you can also convert an `Element` to a String. For this, there are two initializers on `String` added in XMLWrangler.
The first one just converts an `Element` into a `String`. This happens by creating an opening and ending tag (where the beginning tag contains the `attributes` if availble) and putting the `content` of the element in between. If `content` is empty, then no ending tag is created and the opening tag is directly closed with `/>`.

```swift
var root = Element(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(object: "child1")
root.content.append(object: Element(name: "child2", content: "some text"))

let xml = String(xml: root) // -> "<root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

If the traditional XML header should also be added, there's a second initializer which takes a version and a document encoding as additional parameters, but otherwise follows the same rules:

```swift
var root = Element(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(object: "child1")
root.content.append(object: Element(name: "child2", content: "some text"))

let xml = String(xmlDocumentRoot: root, version: Version(major: 1), encoding: .utf8)
// -> "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

For more information on `Version` see [SemVer](https://github.com/sersoft-gmbh/semver).
Please note that currently XMLWrangler only supports serializing documents for the following encodings:

- UTF-8
- UTF-16
- ASCII

Both initializers can take an additional parameter `options` which contains a set of options to control the serialization behaviour. Currently the following options are possible:

- `.pretty`: Use pretty formatting. This adds newlines around the tags to make the resulting XML more readable. This is usually not needed for processing XML.
- `.singleQuoteAttributes`: When this option is present, then attributes of elements will be enclosed in single quotes (') instead of double quotes (").


### Type safety

XMLWrangler will always extract all content and attributes as `String`. This is because XML itself does not differentiate between types like e.g. JSON does. There is an extension on `Element.Content` defining a `converted()` func, though, which should cover the most basic types. The easiest way to convert the content to your type is to make your type conform to `LosslessStringConvertible`.
However, you can always add an extension to `Element.Content` to make extracting other types easier:

```swift
extension Element.Content {
    func convertedToMyType() -> MyType? {
        guard case .string(let str) = self else { return nil }
        return MyType(str) // Create `MyType` from `str`.
    }
}
```

## Possible Features

While not yet integrated, the following features might provide added value and could make it into XMLWrangler in the future:

- Extracting "KeyPaths": It could be useful to directly extract a path. It would not be necessary to extract every single element then.

## Contributing

If you find a bug / like to see a new feature in XMLWrangler there are a few ways of helping out:

- If you can fix the bug / implement the feature yourself please do and open a PR.
- If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
- If you can't do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.


## License

See [LICENSE](./LICENSE) file.
