import 'dart:convert';

import 'package:xml/xml.dart';

class XmlJsonConverter {
  //   XML -> JSON
 
  static String xmlToJson(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final root = document.rootElement;

    final jsonMap = {
      root.name.local: _xmlElementToMap(root),
    };

    return const JsonEncoder.withIndent('  ')
        .convert(jsonMap);
  }

  static dynamic _xmlElementToMap(XmlElement element) {
    if (element.children.whereType<XmlElement>().isEmpty) {
      return element.innerText.trim();
    }

    var result = {};

    for (final child
      in element.children.whereType<XmlElement>()) {
      result[child.name.local] =
        _xmlElementToMap(child);
    }

    return result;
  }

  //  JSON -> XML
 
  static String jsonToXml(String jsonString) {
    final dynamic map = jsonDecode(jsonString);

    final builder = XmlBuilder();

    final rootKey = map.keys.first;

    _buildXml(builder, rootKey, map[rootKey]);

    final document = builder.buildDocument();

    return document.toXmlString(pretty: true);
  }

  static void _buildXml(
    XmlBuilder builder,
    String key,
    dynamic value,
  ) {
    builder.element(
      key,
      nest: () {
        if (value is Map) {
          value.forEach((k, v) {
            _buildXml(builder, k, v);
          });
        } else {
          builder.text(value.toString());
        }
      },
    );
  }
}