// Custom map implementation using a singly-linked list of entries.

class _Entry<K, V> {
  K key;
  V value;
  _Entry<K, V>? next;
  _Entry(this.key, this.value);
}

class CustomMap<K, V> {
  _Entry<K, V>? _head;
  int _length = 0;

  CustomMap();

  int get length => _length;
  bool get isEmpty => _length == 0;
  bool get isNotEmpty => _length != 0;

  V? put(K key, V value) {
    var cur = _head;
    while (cur != null) {
      if (cur.key == key) {
        final old = cur.value;
        cur.value = value;
        return old;
      }
      cur = cur.next;
    }
    final e = _Entry<K, V>(key, value);
    e.next = _head;
    _head = e;
    _length++;
    return null;
  }

  V? get(K key) {
    var cur = _head;
    while (cur != null) {
      if (cur.key == key) return cur.value;
      cur = cur.next;
    }
    return null;
  }

  V? operator [](K key) => get(key);

  void operator []=(K key, V value) => put(key, value);

  bool containsKey(K key) {
    var cur = _head;
    while (cur != null) {
      if (cur.key == key) return true;
      cur = cur.next;
    }
    return false;
  }

  V? remove(K key) {
    if (_head == null) return null;
    if (_head!.key == key) {
      final old = _head!.value;
      _head = _head!.next;
      _length--;
      return old;
    }
    var prev = _head;
    var cur = _head!.next;
    while (cur != null) {
      if (cur.key == key) {
        final old = cur.value;
        prev!.next = cur.next;
        _length--;
        return old;
      }
      prev = cur;
      cur = cur.next;
    }
    return null;
  }

  void clear() {
    _head = null;
    _length = 0;
  }

  Iterable<K> get keys sync* {
    var cur = _head;
    while (cur != null) {
      yield cur.key;
      cur = cur.next;
    }
  }

  Iterable<V> get values sync* {
    var cur = _head;
    while (cur != null) {
      yield cur.value;
      cur = cur.next;
    }
  }

  void forEach(void Function(K, V) action) {
    var cur = _head;
    while (cur != null) {
      action(cur.key, cur.value);
      cur = cur.next;
    }
  }
}
