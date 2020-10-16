# XMLWrangler

[![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/XMLWrangler.svg?style=flat)](https://github.com/sersoft-gmbh/XMLWrangler/releases/latest)
![Tests](https://github.com/sersoft-gmbh/XMLWrangler/workflows/Tests/badge.svg)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c997088f35484726bb1bc6167f074cc4)](https://www.codacy.com/app/ffried/XMLWrangler?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/XMLWrangler&amp;utm_campaign=Badge_Grade)
[![codecov](https://codecov.io/gh/sersoft-gmbh/XMLWrangler/branch/master/graph/badge.svg)](https://codecov.io/gh/sersoft-gmbh/XMLWrangler)
[![jazzy](https://raw.githubusercontent.com/sersoft-gmbh/XMLWrangler/gh-pages/badge.svg?sanitize=true)](https://sersoft-gmbh.github.io/XMLWrangler)

Easily deal with XMLs in Swift.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/xmlwrangler.git", from: "5.0.0"),
```

## Compatibility

-  For Swift up to version 5.2, use XMLWrangler version 3.x.y.
-  For Swift as of version 5.3, use XMLWrangler version 5.x.y.

## Usage

### XMLElement

Every element in an XML is represented by the `XMLElement` struct. It has three properties, `name` which reflects the element's tag name, `attributes` which contains all attributes of the element and `content` which describes the content of the element.
The content is an collection whose `Element` is an enum. The enum has two cases: `.string` and `.element`. The order in the collection is the order in which the content has been found. So if an element first contains some text, then contains a child element and finally again some text,  `content` will contain a `.string` whose associated `StringPart` is the first text. Next there would be a `.element` whose associated `XMLElement` would be the child element. Finally, there would be another `.string` with the last text.

While you can create an `XMLElement` with a content of `[.string("abc"), .string("def"), .element(XMLElement(name: "test"))]`, and it would also lead to valid XML, it could be cleaned up to `[.string("abcdef"), .element(XMLElement(name: "test"))]`. To achieve that, it's recommended to use the various `append` functions on `XMLElement.content` or even `XMLElement` directly when you can't assure that the content is cleaned upon creation. If your element was created with an empty content (`[]`), and you append each of the content elements above, the `append` functions make sure that they append the "def" string to the first "abc" string instead of adding another `.string` to the content. If for some reason you still end up with a situation where your content has consecutive `.string` elements, there's a convenience function `compress()` (or it's non-mutating sibling `compressed()`), which merges these `.string` elements into one.

An `XMLElement` can be compared to another element and is considered equal if all three properties (`name`, `attributes` and `content`) are equal. This means that for a big tree, all children of the root element will be compared. So be careful when comparing big trees and fall back to manually comparing `name` and/or `attributes` if necessary. `XMLElement` also conforms to `Identifiable` and uses the `name` as `id`.

Both, serializing and parsing XMLs with XMLWrangler relies on `XMLElement`.

### Parsing XMLs

Parsing existing XMLs can be done using the `Parser` class. You can instantiate a parser with either a given `Data` object or a `String` containing the XML.

Once you have a parser ready, you can call `parse()` on it, and it'll try to parse the XML. If that succeeds, it'll return the parsed root object. Otherwise it throws whatever error happend along the way. Errors thrown are the ones created by `Foundation.XMLParser`.

```swift
do {
    let xml = """
              <?xml version='1.0' encoding='UTF-8'?>
              <root myattr='myvalue'>
                  <child1/>
                  <child2>some text</child2>
              </root>
              """
    let parser = Parser(string: xml)
    let rootElement = try parser.parse()
} catch {
    print("Something went wrong while parsing: \(error)")
}
```

In this example, `root.name.rawValue` would of course be `"root"`. `rootElement.content` would contain two `.element`s. The first would have a associated `XMLElement` with a `name` of `"child1"` and an empty `content`. The `name` of `XMLElement` of the second `.element` would be `"child2"` and its content would contain one `.string` having `"some text"` associated. `root.attributes` would contain the value `"myvalue"` for the key `"myattr"`.

### Serializing XMLElements

Since you can parse XMLs, you can also convert an `XMLElement` to a String. For this, there are two initializers on `String` added in XMLWrangler.
The first one just converts an `XMLElement` into a `String`. This happens by creating an opening and ending tag (where the beginning tag contains the `attributes` if available) and putting the `content` of the element in between. If `content` is empty, then no ending tag is created and the opening tag is directly closed with `/>`. Also, `content` is compressed (using the aforementioned `compress` function) before being serialized.

```swift
var root = XMLElement(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(element: "child1")
root.content.append(element: XMLElement(name: "child2", content: "some text"))

let xml = String(xml: root) // -> "<root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

If the traditional XML header should also be added, there's a second initializer which takes a version and a document encoding as additional parameters, but otherwise follows the same rules:

```swift
var root = XMLElement(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(element: "child1")
root.content.append(element: XMLElement(name: "child2", content: "some text"))

let xml = String(xmlDocumentRoot: root, version: Version(major: 1), encoding: .utf8)
// -> "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

For more information on `Version` see [SemVer](https://github.com/sersoft-gmbh/semver) but note that only `major` and `minor` are used for XMLs.
Please note that currently XMLWrangler only supports serializing documents for the following encodings:

-   UTF-8
-   UTF-16
-   ASCII

Both initializers can take an additional parameter `options` which contains a set of options to control the serialization behaviour. Currently the following options are possible:

-   `.pretty`: Use pretty formatting. This adds newlines around the tags to make the resulting XML more readable. This is usually not needed for processing XML.
-   `.singleQuoteAttributes`: When this option is present, then attributes of elements will be enclosed in single quotes (') instead of double quotes (").

### Type safety

XMLWrangler will always extract all content and attributes as `String`. This is because XML itself does not differentiate between types like e.g. JSON does.
However, there are many helper functions to safely look up and convert content and attributes of an `XMLElement`:

-   First, there are helpers to extract all child elements with a given name: `XMLElement.elements(named:)`
-   Next, there are helpers to extract an element at a given path: `XMLElement.element(at:)`
-   Another helper allows to extract attributes of an element: `XMLElement.attribute(for:)`.
-   It is then also possible to convert those attributes (for some types like e.g. `RawRepresentable` you don't need to pass a `converter`): `XMLElement.convertedAttribute(for:converter:)`
-   Last but not least you can extract the string content of an Element: `XMLElement.stringContent()`
-   And of course as you can with attributes, you can also convert string content: `XMLElement.convertedStringContent(converter:)`

All these methods throw an error (`LookupError`) when something went wrong instead of returning optionals. If you prefern an optional, you can always use `try?`.
For more information also check the header docs which describe these methods a little closer.

## Possible Features

While not yet integrated, the following features might provide added value and could make it into XMLWrangler in the future:

-   Indention support for serializing and parsing.
-   Extracting "KeyPaths": It could be useful to directly extract a path. It would not be necessary to extract every single element then.

## Documentation

The API is documented using header doc. If you prefer to view the documentation as a webpage, there is an [online version](https://sersoft-gmbh.github.io/XMLWrangler) available for you.

## Contributing

If you find a bug / like to see a new feature in XMLWrangler there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR.
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.
