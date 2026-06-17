import '../models/tree_node.dart';
import '../collections/custom_list.dart';

class SearchService {
  static CustomList<TreeNode> searchByTag(
    TreeNode root,
    String tag,
  ) {
    CustomList<TreeNode> result = CustomList<TreeNode>();

    if (root.tagName == tag) {
      result.add(root);
    }

    for (final child in root.children) {
      result.addAll(searchByTag(child, tag));
    }

    return result;
  }

  static CustomList<TreeNode> searchByText(
    TreeNode root,
    String text,
  ) {
    CustomList<TreeNode> result = CustomList<TreeNode>();

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