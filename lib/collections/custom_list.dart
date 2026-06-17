// Custom singly-linked list implementation without using built-in List

class _Node<T> {
  T value;
  _Node<T>? next;
  _Node(this.value);
}

class CustomList<T> extends Iterable<T> {
  _Node<T>? _head;
  int _length = 0;

  CustomList();

  @override
  int get length => _length;

  @override
  bool get isEmpty => _length == 0;

  @override
  bool get isNotEmpty => _length != 0;

  void add(T value) {
    final node = _Node<T>(value);
    if (_head == null) {
      _head = node;
    } else {
      var cur = _head;
      while (cur!.next != null) {
        cur = cur.next;
      }
      cur.next = node;
    }
    _length++;
  }

  void addAll(Iterable<T> items) {
    for (final v in items) {
      add(v);
    }
  }

  void insert(int index, T value) {
    if (index < 0 || index > _length) throw RangeError.index(index, this, 'index');
    final node = _Node<T>(value);
    if (index == 0) {
      node.next = _head;
      _head = node;
    } else {
      var cur = _head;
      for (var i = 0; i < index - 1; i++) {
        cur = cur!.next;
      }
      node.next = cur!.next;
      cur.next = node;
    }
    _length++;
  }

  T removeAt(int index) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this, 'index');
    _Node<T>? removed;
    if (index == 0) {
      removed = _head;
      _head = _head!.next;
    } else {
      var cur = _head;
      for (var i = 0; i < index - 1; i++) {
        cur = cur!.next;
      }
      removed = cur!.next;
      cur.next = removed!.next;
    }
    _length--;
    return removed!.value;
  }

  bool remove(T value) {
    if (_head == null) return false;
    if (_head!.value == value) {
      _head = _head!.next;
      _length--;
      return true;
    }
    var prev = _head;
    var cur = _head!.next;
    while (cur != null) {
      if (cur.value == value) {
        prev!.next = cur.next;
        _length--;
        return true;
      }
      prev = cur;
      cur = cur.next;
    }
    return false;
  }

  T operator [](int index) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this, 'index');
    var cur = _head;
    for (var i = 0; i < index; i++) {
      cur = cur!.next;
    }
    return cur!.value;
  }

  void operator []=(int index, T value) {
    if (index < 0 || index >= _length) throw RangeError.index(index, this, 'index');
    var cur = _head;
    for (var i = 0; i < index; i++) {
      cur = cur!.next;
    }
    cur!.value = value;
  }

  int indexOf(T value) {
    var cur = _head;
    var i = 0;
    while (cur != null) {
      if (cur.value == value) return i;
      cur = cur.next;
      i++;
    }
    return -1;
  }

  @override
  bool contains(Object? element) {
    if (element is T) return indexOf(element) != -1;
    return false;
  }

  void clear() {
    _head = null;
    _length = 0;
  }

  @override
  Iterator<T> get iterator => _CustomListIterator<T>(_head);
}

class _CustomListIterator<T> implements Iterator<T> {
  _Node<T>? _currentNode;
  _Node<T>? _nextNode;

  _CustomListIterator(_Node<T>? head) {
    _nextNode = head;
  }

  @override
  T get current => _currentNode!.value;

  @override
  bool moveNext() {
    if (_nextNode == null) return false;
    _currentNode = _nextNode;
    _nextNode = _currentNode!.next;
    return true;
  }
}
