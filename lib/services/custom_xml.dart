// Minimal custom XML parser and builder replacement for package:xml
// Supports elements, attributes, text, and self-closing tags.

class CustomXmlName {
  final String local;
  CustomXmlName(this.local);
}

class CustomXmlAttribute {
  final CustomXmlName name;
  final String value;
  CustomXmlAttribute({required this.name, required this.value});
}

class CustomXmlElement {
  final CustomXmlName name;
  final List<CustomXmlAttribute> attributes = [];
  final List<CustomXmlElement> children = [];
  String? text;
  CustomXmlElement? parent;

  CustomXmlElement(this.name);

  Iterable<CustomXmlElement> get childrenElements => children;

  String get innerText {
    if (children.isEmpty) return text?.trim() ?? '';
    final buffer = StringBuffer();
    for (final c in children) {
      buffer.write(c.innerText);
    }
    return buffer.toString();
  }
}

class CustomXmlDocument {
  final CustomXmlElement rootElement;
  CustomXmlDocument(this.rootElement);

  static CustomXmlDocument parse(String input) {
    final parser = _CustomXmlParser(input);
    return CustomXmlDocument(parser.parse());
  }

  String toXmlString({bool pretty = false}) {
    final sb = StringBuffer();
    void emit(CustomXmlElement e, int indent) {
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
        final t = pretty ? '${ind}  ${e.text}' : e.text;
        if (pretty && e.children.isEmpty) {
          sb.write(t);
        } else if (pretty && e.children.isNotEmpty) {
          sb.write('${ind}  ${e.text}\n');
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

class CustomXmlBuilder {
  final CustomXmlElement _root = CustomXmlElement(CustomXmlName('root'));
  final List<CustomXmlElement> _stack = [];

  CustomXmlBuilder() {
    _stack.add(_root);
  }

  void element(String name, {void Function()? nest}) {
    final elem = CustomXmlElement(CustomXmlName(name));
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

  CustomXmlDocument buildDocument() {
    if (_root.children.isEmpty) throw StateError('No root element built');
    return CustomXmlDocument(_root.children.first);
  }
}

String _escape(String s) => s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;');

class _CustomXmlParser {
  final String _s;
  int _i = 0;
  _CustomXmlParser(this._s);

  bool _startsWith(String pat) => _s.startsWith(pat, _i);

  void _skipWhitespace() {
    while (_i < _s.length && _s[_i].trim().isEmpty) {
      _i++;
    }
  }

  CustomXmlElement parse() {
    _skipPrologAndComments();
    _skipWhitespace();
    final root = _parseElement();
    return root;
  }

  void _skipPrologAndComments() {
    while (true) {
      _skipWhitespace();
      if (_startsWith('<?')) {
        final idx = _s.indexOf('?>', _i);
        if (idx == -1) {
          _i = _s.length;
          return;
        }
        _i = idx + 2;
      } else if (_startsWith('<!--')) {
        final idx = _s.indexOf('-->', _i);
        if (idx == -1) {
          _i = _s.length;
          return;
        }
        _i = idx + 3;
      } else {
        break;
      }
    }
  }

  CustomXmlElement _parseElement() {
    _skipWhitespace();
    if (_i >= _s.length || _s[_i] != '<') throw FormatException('Expected < at $_i');
    _i++; // skip '<'
    final name = _readName();
    final elem = CustomXmlElement(CustomXmlName(name));
    _skipWhitespace();
    while (_i < _s.length && _s[_i] != '>' && !_startsWith('/>')) {
      final c = _s[_i];
      if (c.trim().isEmpty) {
        _i++;
        continue;
      }
      if (_s[_i] == '/') break;
      final attrName = _readName();
      _skipWhitespace();
      if (_i < _s.length && _s[_i] == '=') {
        _i++;
        _skipWhitespace();
        final val = _readAttributeValue();
        elem.attributes.add(CustomXmlAttribute(name: CustomXmlName(attrName), value: val));
      }
      _skipWhitespace();
    }
    if (_startsWith('/>')) {
      _i += 2;
      return elem;
    }
    if (_i < _s.length && _s[_i] == '>') {
      _i++;
    }
    final buffer = StringBuffer();
    while (true) {
      _skipWhitespace();
      if (_startsWith('</')) {
        if (buffer.isNotEmpty) elem.text = buffer.toString().trim();
        _i += 2; // skip </
        final endName = _readName();
        _skipWhitespace();
        if (_i < _s.length && _s[_i] == '>') _i++;
        return elem;
      } else if (_startsWith('<')) {
        final child = _parseElement();
        child.parent = elem;
        elem.children.add(child);
      } else {
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
    final start = _i;
    while (_i < _s.length && !_s[_i].trim().isEmpty && _s[_i] != '>') _i++;
    return _s.substring(start, _i);
  }
}
