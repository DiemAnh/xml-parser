import 'package:xml_app/collections/simple_list.dart';

class XmlName {
  final String local;
  XmlName(this.local);
}

class XmlAttribute {
  final XmlName name;
  final String value;
  XmlAttribute({required this.name, required this.value});
}

class XmlElement {
  final XmlName name;
  final SimpleList<XmlAttribute> attributes = SimpleList<XmlAttribute>();
  final SimpleList<XmlElement> children = SimpleList<XmlElement>();
  String? text;
  XmlElement? parent;

  XmlElement(this.name);

  Iterable<XmlElement> get childrenElements => children;

  String get innerText {
    if (children.isEmpty) return text?.trim() ?? '';
    final buffer = StringBuffer();
    for (final c in children) {
      buffer.write(c.innerText);
    }
    return buffer.toString();
  }
}

class XmlDocument {
  final XmlElement rootElement;
  XmlDocument(this.rootElement);

  static XmlDocument parse(String input) {
    final parser = _SimpleXmlParser(input);
    return XmlDocument(parser.parse());
  }

  String toXmlString({bool pretty = false}) {
    final sb = StringBuffer();
    void emit(XmlElement e, int indent) {
      final ind = pretty ? '  ' * indent : '';
      sb.write('$ind<${e.name.local}');
      for (final a in e.attributes) {
        sb.write(' ${a.name.local}="${_escape(a.value)}"');
      }
      if (e.children.isEmpty && (e.text == null || e.text!.isEmpty)) {
        sb.write('/>');
        if (pretty) sb.writeln();
        return;
      }
      sb.write('>');
      if (pretty && (e.children.isNotEmpty)) sb.writeln();
      if (e.text != null && e.text!.isNotEmpty) {
        final t = pretty ? ind + '  ' + e.text! : e.text;
        if (pretty && e.children.isEmpty) {
          sb.write(t);
        } else if (pretty && e.children.isNotEmpty) {
          sb.write(ind + '  ' + e.text! + '\n');
        } else {
          sb.write(t);
        }
      }
      for (final c in e.children) {
        emit(c, indent + 1);
      }
      if (pretty && e.children.isNotEmpty) sb.write(ind);
      sb.write('</${e.name.local}>');
      if (pretty) sb.writeln();
    }

    emit(rootElement, 0);
    return sb.toString();
  }
}

class XmlBuilder {
  final XmlElement _root = XmlElement(XmlName('root'));
  final SimpleList<XmlElement> _stack = SimpleList<XmlElement>();

  XmlBuilder() {
    _stack.add(_root);
  }

  void element(String name, {void Function()? nest}) {
    final elem = XmlElement(XmlName(name));
    final parent = _stack.last;
    elem.parent = parent;
    parent.children.add(elem);
    if (nest != null) {
      _stack.add(elem);
      nest();
      _stack.removeLast();
    }
  }

  void text(String t) {
    final cur = _stack.last;
    cur.text = (cur.text ?? '') + t;
  }

  XmlDocument buildDocument() {
    if (_root.children.isEmpty) throw StateError('No root element built');
    return XmlDocument(_root.children.first);
  }
}

String _escape(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

class _SimpleXmlParser {
  final String _s;
  int _i = 0;
  _SimpleXmlParser(this._s);

  bool _startsWith(String pat) => _s.startsWith(pat, _i);

  void _skipWhitespace() {
    while (_i < _s.length && _s[_i].trim().isEmpty) {
      _i++;
    }
  }

  XmlElement parse() {
    _skipPrologAndComments();
    _skipWhitespace();
    final root = _parseElement();
    return root;
  }

  void _skipPrologAndComments() {
    while (true) {
      _skipWhitespace();
      if (_startsWith('<?')) {
        // skip until ?>
        final idx = _s.indexOf('?>', _i);
        if (idx == -1) { _i = _s.length; return; }
        _i = idx + 2;
      } else if (_startsWith('<!--')) {
        final idx = _s.indexOf('-->', _i);
        if (idx == -1) { _i = _s.length; return; }
        _i = idx + 3;
      } else {
        break;
      }
    }
  }

  XmlElement _parseElement() {
    _skipWhitespace();
    if (_i >= _s.length || _s[_i] != '<') throw FormatException('Expected < at $_i');
    _i++; // skip '<'
    // read name
    final name = _readName();
    final elem = XmlElement(XmlName(name));
    _skipWhitespace();
    // attributes
    while (_i < _s.length && _s[_i] != '>' && !_startsWith('/>')) {
      final c = _s[_i];
      if (c.trim().isEmpty) { _i++; continue; }
      if (_s[_i] == '/') break;
      final attrName = _readName();
      _skipWhitespace();
      if (_i < _s.length && _s[_i] == '=') {
        _i++;
        _skipWhitespace();
        final val = _readAttributeValue();
        elem.attributes.add(XmlAttribute(name: XmlName(attrName), value: val));
      }
      _skipWhitespace();
    }
    // self-closing
    if (_startsWith('/>')) {
      _i += 2;
      return elem;
    }
    if (_i < _s.length && _s[_i] == '>') {
      _i++;
    }
    // content: text or children
    final buffer = StringBuffer();
    while (true) {
      _skipWhitespace();
      if (_startsWith('</')) {
        if (buffer.isNotEmpty) elem.text = buffer.toString().trim();
        _i += 2; // skip </
        final endName = _readName();
        _skipWhitespace();
        if (_i < _s.length && _s[_i] == '>') {
          _i++;
        }
        if (endName != name) {
          // mismatched end tag - continue anyway
        }
        return elem;
      } else if (_startsWith('<')) {
        // child element
        final child = _parseElement();
        child.parent = elem;
        elem.children.add(child);
      } else {
        // text
        final idx = _s.indexOf('<', _i);
        if (idx == -1) {
          buffer.write(_s.substring(_i));
          _i = _s.length;
        } else {
          buffer.write(_s.substring(_i, idx));
          _i = idx;
        }
      }
    }
  }

  String _readName() {
    final start = _i;
    while (_i < _s.length) {
      final ch = _s[_i];
      if (ch == '>' || ch == '/' || ch == '=' || ch.trim().isEmpty || ch == '<') break;
      _i++;
    }
    return _s.substring(start, _i).trim();
  }

  String _readAttributeValue() {
    _skipWhitespace();
    if (_i >= _s.length) return '';
    final quote = _s[_i];
    if (quote == '"' || quote == "'") {
      _i++;
      final idx = _s.indexOf(quote, _i);
      if (idx == -1) {
        final val = _s.substring(_i);
        _i = _s.length;
        return val;
      }
      final val = _s.substring(_i, idx);
      _i = idx + 1;
      return val;
    }
    // unquoted
    final start = _i;
    while (_i < _s.length && !_s[_i].trim().isEmpty && _s[_i] != '>') {
      _i++;
    }
    return _s.substring(start, _i);
  }
}
