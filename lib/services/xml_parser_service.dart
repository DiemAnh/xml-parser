import 'package:xml_app/services/simple_xml.dart';

import '../models/tree_node.dart';
import '../models/attribute.dart';

class XmlParserService {
  static TreeNode parseXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final rootElement = document.rootElement;

    return _parseElement(rootElement);
  }

  static TreeNode _parseElement(XmlElement element) {
    final node = TreeNode(
      tagName: element.name.local,
    );

    // attributes
    for (final attr in element.attributes) {
      node.attributes.add(
        Attribute(
          name: attr.name.local,
          value: attr.value,
        ),
      );
    }

    // text
    final text = element.innerText.trim();

    if (text.isNotEmpty &&
        element.children.whereType<XmlElement>().isEmpty) {
      node.text = text;
    }

    // children
    for (final child
        in element.children.whereType<XmlElement>()) {
      final childNode = _parseElement(child);

      node.addChild(childNode);
    }

    return node;
  }
}