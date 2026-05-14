import 'package:xml_app/models/attribute.dart';

class TreeNode {
  String tagName;

  List<Attribute> attributes;

  String? text;

  TreeNode? parent;

  List<TreeNode> children;

  TreeNode({
    required this.tagName,
    this.text,
    this.parent,
    List<Attribute>? attributes,
    List<TreeNode>? children,
  })  : attributes = attributes ?? [],
        children = children ?? [];

  void addChild(TreeNode child) {
    child.parent = this;
    children.add(child);
  }
}