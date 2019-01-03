# XMLWrangler
![GitHub release](https://img.shields.io/github/release/sersoft-gmbh/XMLWrangler.svg?style=flat)
![CI Status](https://travis-ci.com/sersoft-gmbh/XMLWrangler.svg?branch=master)
[![Codacy Badge](https://api.codacy.com/project/badge/Grade/c997088f35484726bb1bc6167f074cc4)](https://www.codacy.com/app/ffried/XMLWrangler?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=sersoft-gmbh/XMLWrangler&amp;utm_campaign=Badge_Grade)

Easily deal with XMLs in Swift.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/xmlwrangler.git", from: "3.0.0"),
```

## Usage

### Element

Every element in an XML is represented by the `Element` struct. It has three properties, `name` which reflects the element's tag name, `attributes` which contains all attributes of the element as a Dictionary and `content` which describes the content of the element.
The content is an array of a `Content` enum. The enum has two cases: `.string` and `.object`. The order in the array is the order in which the content has been found. So if an element first contains some text, then contains a child element and finally again some text, the `content` array will contain a `.string` whose associated `String` is the first text. Next there would be a `.object` whose associated `Element` would be the child element. Finally, there would be another `.string` with the last text.

While you can create an `Element` with a content of `[.string("abc"), .string("def"), .object("test")]`, and it would also lead to valid XML, it could be cleaned up to `[.string("abcdef"), .object("test")]`. To achieve that, it's recommended to use the various `append` funcs on `Element.content` or even `Element` directly when you can't assure that the content is cleaned upon creation. If your element was created with an empty content (`[]`), and you append each of the content elements above, the `append` funcs make sure that they append the "def" string to the first "abc" string instead of adding another `.string` to the content array. If for some reason you still end up with a situation where your content has consecutive `.string` elements, there's a convenience function `compress()` (or it's non-mutating sibling `compressed()`), which merges these `.string` elements into one.

An `Element` can be compared to another element and is considered equal if all three properties (`name`, `attributes` and `content`) are equal. This means that for a big tree, all children of the root element will be compared. So be careful when comparing big trees and fall back to manually comparing `name` and/or `attributes` if necessary.

Both, serializing and parsing XMLs with XMLWrangler relies on `Element`.

### Parsing XMLs

Parsing existing XMLs can be done using the `Parser` class. You can instantiate a parser with either a given `Data` object or a `String` containing the XML. The latter might return `nil` if the String can't be converted to a `Data` object.

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

In this example, `root.name.rawValue` would of course be `"root"`. `rootElement.content` would be an array containing two `.object`. The first would have a associated `Element` with a `name` of `"child1"` and a `content` which is an empty array. The `name` of `Element` of the second `.object` would be `"child2"` and its content would contain one `.string` with `"some text"` as associated String. `root.attributes` would contain the value `"myvalue"` for the key `"myattr"`.

### Serializing Elements

Since you can parse XMLs, you can also convert an `Element` to a String. For this, there are two initializers on `String` added in XMLWrangler.
The first one just converts an `Element` into a `String`. This happens by creating an opening and ending tag (where the beginning tag contains the `attributes` if available) and putting the `content` of the element in between. If `content` is empty, then no ending tag is created and the opening tag is directly closed with `/>`. Also, `content` is compressed (using the aforementioned `compress` function) before being serialized.

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
However, there are many helper functions to safely look up and convert content and attributes of an `Element`:

-   First, there are helpers to extract all child elements with a given name: `Element.elements(named:)`
-   Next, there are helpers to extract an element at a given path: `Element.element(at:)`
-   Another helper allows to extract attributes of an element: `Element.attribute(for:)`.
-   It is then also possible to convert those attributes (for some types like e.g. `RawRepresentable` you don't need to pass a `converter`): `Element.convertedAttribute(for:converter:)`
-   Last but not least you can extract the string content of an Element: `Element.stringContent()`
-   And of course as you can with attributes, you can also convert string content: `Element.convertedStringContent(converter:)`

There are also mixtures of all of these, so that you can e.g. extract and convert an attribute of a child element at a given path: `Element.convertedAttribute(for:ofElementAt:converter:)`

All these methods throw an error (`LookupError`) when something went wrong instead of returning optionals. If you prefern an optional, you can always use `try?`.
For more information also check the header docs which describe these methods a little closer.

## Possible Features

While not yet integrated, the following features might provide added value and could make it into XMLWrangler in the future:

-   Indention support for serializing and parsing.
-   Extracting "KeyPaths": It could be useful to directly extract a path. It would not be necessary to extract every single element then.

## Contributing

If you find a bug / like to see a new feature in XMLWrangler there are a few ways of helping out:

-   If you can fix the bug / implement the feature yourself please do and open a PR.
-   If you know how to code (which you probably do), please add a (failing) test and open a PR. We'll try to get your test green ASAP.
-   If you can do neither, then open an issue. While this might be the easiest way, it will likely take the longest for the bug to be fixed / feature to be implemented.

## License

See [LICENSE](./LICENSE) file.