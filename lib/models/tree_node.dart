import 'package:xml_app/models/attribute.dart';
import 'package:xml_app/collections/simple_list.dart';

class TreeNode {
  String tagName;

  SimpleList<Attribute> attributes;

  String? text;

  TreeNode? parent;

  SimpleList<TreeNode> children;

  TreeNode({
    required this.tagName,
    this.text,
    this.parent,
    SimpleList<Attribute>? attributes,
    SimpleList<TreeNode>? children,
  })  : attributes = attributes ?? SimpleList<Attribute>(),
        children = children ?? SimpleList<TreeNode>();

  void addChild(TreeNode child) {
    child.parent = this;
    children.add(child);
  }
}