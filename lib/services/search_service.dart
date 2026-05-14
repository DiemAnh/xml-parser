import '../models/tree_node.dart';

class SearchService {
  static List<TreeNode> searchByTag(
    TreeNode root,
    String tag,
  ) {
    List<TreeNode> result = [];

    if (root.tagName == tag) {
      result.add(root);
    }

    for (final child in root.children) {
      result.addAll(
        searchByTag(child, tag),
      );
    }

    return result;
  }

  static List<TreeNode> searchByText(
    TreeNode root,
    String text,
  ) {
    List<TreeNode> result = [];

    if (root.text != null &&
        root.text!
            .toLowerCase()
            .contains(text.toLowerCase())) {
      result.add(root);
    }

    for (final child in root.children) {
      result.addAll(
        searchByText(child, text),
      );
    }

    return result;
  }
}