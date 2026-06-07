import '../models/tree_node.dart';

class SearchService {
  static Iterable<TreeNode> searchByTag(
    TreeNode root,
    String tag,
  ) sync* {
    if (root.tagName == tag) {
      yield root;
    }

    for (final child in root.children) {
      yield* searchByTag(child, tag);
    }
  }

  static Iterable<TreeNode> searchByText(
    TreeNode root,
    String text,
  ) sync* {
    if (root.text != null &&
        root.text!
            .toLowerCase()
            .contains(text.toLowerCase())) {
      yield root;
    }

    for (final child in root.children) {
      yield* searchByText(child, text);
    }
  }
}