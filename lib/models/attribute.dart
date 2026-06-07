import 'dart:collection';

base class Attribute extends LinkedListEntry<Attribute> {
  String name;
  String value;

  Attribute({
    required this.name,
    required this.value,
  });
}