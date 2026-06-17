import 'package:xml_app/services/custom_xml.dart';

import '../models/tree_node.dart';
import '../models/attribute.dart';

class XmlParserService {
  static TreeNode parseXml(String xmlString) {
    final document = CustomXmlDocument.parse(xmlString);

    final rootElement = document.rootElement;

    return _parseElement(rootElement);
  }

  static TreeNode _parseElement(CustomXmlElement element) {
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

    if (text.isNotEmpty && element.children.isEmpty) {
      node.text = text;
    }

    // children
    for (final child in element.children) {
      final childNode = _parseElement(child);

      node.addChild(childNode);
    }

    return node;
  }
}