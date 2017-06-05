# XMLWrangler

Easily deal with XMLs in Swift.

## Usage

### Element

Every element in an XML is represented by the `Element` struct. It has three properties, `name` which reflects the element's tag name, `attributes` which contains all attributes of the element as a Dictionary and `content` which describes the content of the element.
The content itself can be of three types: `.empty`, `.string` or `.objects`. If the element contains only text, its `content` will be `.string` and the associated `String` will reflect the text inside the element. If the element has itself nested elements, its `content` will be `.objects` and associated value is the array of all `Element` objects under the element.
You can append strings and elements to the content using the `append` funcs. However, unless you also pass `convertIfNecessary` as `true`, it will only append the content you passed if it's of the same type as `content`. E.g. if `content` is `.empty`, it would never append anything. If it's `.string` and you try to append one or more `Element`'s it would also not append anything. Passing `convertIfNecessary` as `true` will always convert the content to the appropriate type in this case. However this might result in data loss if you e.g. have a content which is `.objects` containing some elements and append a String with `convertIfNecessary` set to `true`, the elements array will be lost and `content` is converted to a string.

An `Element` can be compared to another element and is considered equal if all three properties (`name`, `attributes` and `content`) are equal. This means that for a big tree, all children of the root element will be compared. So be careful when comparing big trees and fall back to manually comparing `name` and/or `attributes` if necessary.

Both, serializing and parsing XMLs with XMLWrangler relies on `Element`.

### Parsing XMLs

Parsing existing XMLs can be done using the `Parser` class. You can instantiate a parser with either a given `Data` object or a `String` containing the XML. The latter might return `nil` if the String can't be converted to a `Data` object.

Once you have a parser ready, you can call `parse()` on it, and it'll try to parse the XML. If that succeeds, it'll return the parsed root object. Otherwise it throws whatever error happend along the way. Errors thrown are the once `Foundation.XMLParser` produces.

```swift
let xml = "<?xml version='1.0' encoding='UTF-8'?><root myattr='myvalue'><child1/><child2>some text</child2></root>"
guard let parser = Parser(string: xml) else { fatalError("Check your xml string. And please don't use `fatalError` ;)") }
do {
    let rootElement = try parser.parse()
} catch {
    print("Something went wrong while parsing: \(error)")
}
```

In this example, `root.name` would of course be `"root"`. `rootElement.content` would be `.objects` and have two objects in the array. The first would have a `name` of `"child1"` and a `content` which is `.empty`. The `name` of second one would be `"child2"` and its content is `.string` with `"some text"` as associated String. `root.attributes` would contain the value `"myvalue"` for the key `"myattr"`.


### Serializing Elements

Since you can parse XMLs, you can also convert an `Element` to a String. For this, there are two initializers on `String` added in XMLWrangler.
The first one just converts an `Element` into a `String`. This happens by creating an opening and ending tag (where the beginning tag contains the `attributes` if availble) and putting the `content` of the element in between. If the `content` is empty, the no ending tag is created and the opening tag is directly closed with `/>`.

```swift
var root = Element(name: "root", attributes: ["myattr": "myvalue"], content: .objects([]))
root.content.append(object: "child1")
root.content.append(object: Element(name: "child2", content: "some text"))

let xml = String(xml: root) // -> "<root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

If the traditional xml header should also be added, there's a second initializer which takes a version and a document encoding as additional parameters, but otherwise follows the same rules:

```swift
var root = Element(name: "root", attributes: ["myattr": "myvalue"], content: .objects([]))
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

XMLWrangler will always extract all content and attributes as `String`. This is because XML itself does not differentiate between types like e.g. JSON does. There is one extension on `Element.Content` defining a `convert()` func, though, which should cover the most basic types. The easiest way to convert the content to your type is to make your type conform to `LosslessStringConvertible`. For convenience, we made `Int` conform to `LosslessStringConvertible` by calling `Int.init(_ text: String, radix: Int = default)` with a `radix` of 10.
However, you can always add an extension to `Element.Content` to make extracting other types easier:

```swift
extension Element.Content {
    func convertedToMyType() -> MyType? {
        guard case .string(let str) = self else { return nil }
        return MyType(str) // Convert to your type.
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
