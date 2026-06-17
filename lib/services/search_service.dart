import '../models/tree_node.dart';
import '../collections/simple_list.dart';

class SearchService {
  static SimpleList<TreeNode> searchByTag(
    TreeNode root,
    String tag,
  ) {
    SimpleList<TreeNode> result = SimpleList<TreeNode>();

    if (root.tagName == tag) {
      result.add(root);
    }

    for (final child in root.children) {
      result.addAll(searchByTag(child, tag));
    }

    return result;
  }

  static SimpleList<TreeNode> searchByText(
    TreeNode root,
    String text,
  ) {
    SimpleList<TreeNode> result = SimpleList<TreeNode>();

    if (root.text != null &&
        root.text!
            .toLowerCase()
            .contains(text.toLowerCase())) {
      result.add(root);
    }

    for (final child in root.children) {
      result.addAll(searchByText(child, text));
    }

    return result;
  }
}