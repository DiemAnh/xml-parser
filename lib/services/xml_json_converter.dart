import 'dart:convert';

import 'package:xml_app/collections/simple_map.dart';
import 'package:xml_app/services/simple_xml.dart';

class XmlJsonConverter {
  //   XML -> JSON
 
  static String xmlToJson(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final root = document.rootElement;

    final dynamic converted = _xmlElementToMap(root);

    final native = {root.name.local: _toNativeMap(converted)};

    return const JsonEncoder.withIndent('  ').convert(native);
  }

  static dynamic _xmlElementToMap(XmlElement element) {
    if (element.children.whereType<XmlElement>().isEmpty) {
      return element.innerText.trim();
    }

    final SimpleMap<String, dynamic> result = SimpleMap<String, dynamic>();

    for (final child in element.children.whereType<XmlElement>()) {
      result[child.name.local] = _xmlElementToMap(child);
    }

    return result;
  }

  //  JSON -> XML
 
  static String jsonToXml(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);

    final SimpleMap<String, dynamic> map = _toSimpleMap(decoded);

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
        if (value is SimpleMap<String, dynamic>) {
          value.forEach((k, v) {
            _buildXml(builder, k, v);
          });
        } else {
          builder.text(value.toString());
        }
      },
    );
  }

  static dynamic _toNativeMap(dynamic v) {
    if (v is SimpleMap) {
      final Map<String, dynamic> m = {};
      for (final k in v.keys) {
        m[k] = _toNativeMap(v[k]);
      }
      return m;
    }
    return v;
  }

  static SimpleMap<String, dynamic> _toSimpleMap(dynamic decoded) {
    final SimpleMap<String, dynamic> map = SimpleMap<String, dynamic>();
    if (decoded is Map) {
      decoded.forEach((k, v) {
        if (v is Map) {
          map[k] = _toSimpleMap(v);
        } else {
          map[k] = v;
        }
      });
    }
    return map;
  }
}