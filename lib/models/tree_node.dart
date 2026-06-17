import 'package:xml_app/models/attribute.dart';
import 'package:xml_app/collections/custom_list.dart';

class TreeNode {
  String tagName;

  CustomList<Attribute> attributes;

  String? text;

  TreeNode? parent;

  CustomList<TreeNode> children;

  TreeNode({
    required this.tagName,
    this.text,
    this.parent,
    CustomList<Attribute>? attributes,
    CustomList<TreeNode>? children,
  })  : attributes = attributes ?? CustomList<Attribute>(),
        children = children ?? CustomList<TreeNode>();

  void addChild(TreeNode child) {
    child.parent = this;
    children.add(child);
  }
}