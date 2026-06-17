import 'dart:convert';

import 'package:xml_app/collections/custom_map.dart';
import 'package:xml_app/services/custom_xml.dart';

class XmlJsonConverter {
  //   XML -> JSON
 
  static String xmlToJson(String xmlString) {
    final document = CustomXmlDocument.parse(xmlString);

    final root = document.rootElement;

    final dynamic converted = _xmlElementToMap(root);

    final native = {root.name.local: _toNativeMap(converted)};

    return const JsonEncoder.withIndent('  ').convert(native);
  }

  static dynamic _xmlElementToMap(CustomXmlElement element) {
    if (element.children.isEmpty) {
      return element.innerText.trim();
    }

    final CustomMap<String, dynamic> result = CustomMap<String, dynamic>();

    for (final child in element.children) {
      result[child.name.local] = _xmlElementToMap(child);
    }

    return result;
  }

  //  JSON -> XML
 
  static String jsonToXml(String jsonString) {
    final dynamic decoded = jsonDecode(jsonString);

    final CustomMap<String, dynamic> map = _toCustomMap(decoded);

    final builder = CustomXmlBuilder();

    final rootKey = map.keys.first;

    _buildXml(builder, rootKey, map[rootKey]);

    final document = builder.buildDocument();

    return document.toXmlString(pretty: true);
  }

  static void _buildXml(
    CustomXmlBuilder builder,
    String key,
    dynamic value,
  ) {
    builder.element(
      key,
      nest: () {
        if (value is CustomMap<String, dynamic>) {
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
    if (v is CustomMap) {
      final Map<String, dynamic> m = {};
      for (final k in v.keys) {
        m[k] = _toNativeMap(v[k]);
      }
      return m;
    }
    return v;
  }
  static CustomMap<String, dynamic> _toCustomMap(dynamic decoded) {
    final CustomMap<String, dynamic> map = CustomMap<String, dynamic>();
    if (decoded is Map) {
      decoded.forEach((k, v) {
        if (v is Map) {
          map[k] = _toCustomMap(v);
        } else {
          map[k] = v;
        }
      });
    }
    return map;
  }
}