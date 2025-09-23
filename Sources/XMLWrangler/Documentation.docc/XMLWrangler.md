# ``XMLWrangler``

Easily deal with XMLs in Swift.

## Installation

Add the following dependency to your `Package.swift`:
```swift
.package(url: "https://github.com/sersoft-gmbh/xmlwrangler", from: "6.0.0"),
```

## Compatibility

| **Swift**          | **XMLWrangler Package**  |
|--------------------|--------------------------|
| <  5.2.0           | 1.x.y - 3.x.y            |
| >= 5.3.0, < 5.9.0  | 5.x.y                    |
| >= 5.9.0           | 6.x.y                    |

## Usage

### `XMLElement`

Every element in an XML is represented by the ``XMLElement`` struct. It has three properties, ``XMLElement/name`` which reflects the element's tag name, ``XMLElement/attributes`` which contains all attributes of the element and ``XMLElement/content`` which describes the content of the element.
The content is an collection whose ``XMLElement/Content/Element`` is an enum. The enum has two cases: ``XMLElement/Content/Element/string(_:)`` and ``XMLElement/Content/Element/element(_:)``. The order in the collection is the order in which the content has been found. So if an element first contains some text, then contains a child element and finally again some text,  ``XMLElement/content`` will contain a ``XMLElement/Content/Element/string(_:)`` whose associated ``XMLElement/Content/Element/StringPart`` is the first text. Next there would be a ``XMLElement/Content/Element/element(_:)`` whose associated ``XMLElement`` would be the child element. Finally, there would be another ``XMLElement/Content/Element/string(_:)`` with the last text.

While you can create an ``XMLElement`` with a content of `[.string("abc"), .string("def"), .element(XMLElement(name: "test"))]`, and it would also lead to valid XML, it could be cleaned up to `[.string("abcdef"), .element(XMLElement(name: "test"))]`. To achieve that, it's recommended to use the various `append` functions on ``XMLElement/content`` or even ``XMLElement`` directly when you can't assure that the content is cleaned upon creation. If your element was created with an empty content (`[]`), and you append each of the content elements above, the `append` functions make sure that they append the "def" string to the first "abc" string instead of adding another ``XMLElement/Content/Element/string(_:)`` to the content. If for some reason you still end up with a situation where your content has consecutive ``XMLElement/Content/Element/string(_:)`` elements, there's a convenience function ``XMLElement/Content/compress()`` (or it's non-mutating sibling ``XMLElement/Content/compressed()``), which merges these consecutive ``XMLElement/Content/Element/string(_:)`` elements into one.

An ``XMLElement`` can be compared to another element and is considered equal if all three properties (``XMLElement/name``, ``XMLElement/attributes`` and ``XMLElement/content``) are equal. This means that for a big tree, all children of the root element will be compared. So be careful when comparing big trees and fall back to manually comparing ``XMLElement/name`` and/or ``XMLElement/attributes`` if necessary. ``XMLElement`` also conforms to `Identifiable` and uses its ``XMLElement/name`` as `id`.

Both, serializing and parsing XMLs with XMLWrangler relies on ``XMLElement``.

### Parsing XMLs

Parsing existing XMLs can be done using the static functions on ``XMLElement``. You can parse either a given `Data` object or a `String` containing the XML.
If parsing succeeds, the parsed root object is returned. Otherwise whatever error happend along the way is thrown. Errors thrown are the ones created by `Foundation.XMLParser`.

```swift
do {
    let xml = """
              <?xml version='1.0' encoding='UTF-8'?>
              <root myattr='myvalue'>
                  <child1/>
                  <child2>some text</child2>
              </root>
              """
    let root = try XMLElement.parse(xml)
} catch {
    print("Something went wrong while parsing: \(error)")
}
```

In this example, `root.name.rawValue` would of course be `"root"`. `root.content` would contain two `.element`s. The first would have a associated ``XMLElement`` with a `name` of `"child1"` and an empty `content`. The `name` of ``XMLElement`` of the second `.element` would be `"child2"` and its content would contain one `.string` having `"some text"` associated. `root.attributes` would contain the value `"myvalue"` for the key `"myattr"`.

### Serializing XMLElements

Since you can parse XMLs, you can also convert an ``XMLElement`` to a String. For this, there are two functions on ``XMLElement``.
The first one just converts an ``XMLElement`` into a `String`. This happens by creating an opening and ending tag (where the beginning tag contains the ``XMLElement/attributes`` if available) and putting the ``XMLElement/content`` of the element in between. Also, ``XMLElement/content`` is compressed (using the aforementioned ``XMLElement/Content/compress()`` function) before being serialized.

```swift
var root = XMLElement(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(element: "child1")
root.content.append(element: XMLElement(name: "child2", content: "some text"))

let xmlString = xml.serialize() // -> "<root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

If the traditional XML header should also be added, there's a second function which takes a version and a document encoding as additional parameters, but otherwise follows the same rules:

```swift
var root = XMLElement(name: "root", attributes: ["myattr": "myvalue"])
root.content.append(element: "child1")
root.content.append(element: XMLElement(name: "child2", content: "some text"))

let xmlDocumentString = root.serializeAsDocument(at: DocumentVersion(major: 1), using: .utf8)
// -> "<?xml version=\"1.0\" encoding=\"UTF-8\"?><root myattr=\"myvalue\"><child1/><child2>some text</child2></root>"
```

Please note that XMLWrangler does not escape the string based on the given encoding. It simply uses it the generate the document header.

Both functions can take an additional parameter `options` which contains a set of options to control the serialization behaviour. Currently the following options are possible:

-   ``XMLElement/SerializationOptions/pretty``: Use pretty formatting. This adds newlines around the tags to make the resulting XML more readable. This is usually not needed for processing XML.
-   ``XMLElement/SerializationOptions/singleQuoteAttributes``: When this option is present, then attributes of elements will be enclosed in single quotes (') instead of double quotes (").
-   ``XMLElement/SerializationOptions/explicitClosingTag``: This option forces empty elements to be serialized with an explicit closing tag instead of using the shorthand `/>` syntax.

### Type safety

XMLWrangler will always extract all content and attributes as `String` internally. This is because XML itself does not differentiate between types like e.g. JSON does.
However, there are many helper functions to safely look up and convert content and attributes of an ``XMLElement``:

-   First, there are helpers to extract all child elements with a given name: ``XMLElement/elements(named:)``
-   Next, there are helpers to extract an element at a given path: ``XMLElement/element(at:)``
-   Another helper allows to extract attributes of an element: ``XMLElement/attribute(for:)``.
-   It is then also possible to convert those attributes (for some types like e.g. `RawRepresentable` you don't need to pass a `converter`): ``XMLElement/convertedAttribute(for:converter:)``
-   Last but not least you can extract the string content of an Element: ``XMLElement/stringContent()``
-   And of course as you can with attributes, you can also convert string content: ``XMLElement/convertedStringContent(converter:)``

All these methods throw an error (``XMLElement/LookupError``) when something went wrong instead of returning optionals. If you prefern an optional, you can always use `try?`.
For more information also check the header docs which describe these methods a little closer.
