import 'dart:collection';

import 'package:xml_app/models/attribute.dart';

base class TreeNode extends LinkedListEntry<TreeNode> {
  String tagName;

  LinkedList<Attribute> attributes;

  String? text;

  TreeNode? parent;

  LinkedList<TreeNode> children;

  TreeNode({
    required this.tagName,
    this.text,
    this.parent,
    Iterable<Attribute>? attributes,
    Iterable<TreeNode>? children,
  })  : attributes = LinkedList<Attribute>(),
        children = LinkedList<TreeNode>() {
    if (attributes != null) {
      for (final a in attributes) {
        this.attributes.add(a);
      }
    }

    if (children != null) {
      for (final c in children) {
        c.parent = this;
        this.children.add(c);
      }
    }
  }

  void addChild(TreeNode child) {
    child.parent = this;
    children.add(child);
  }
}