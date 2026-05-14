# XML Parser Flutter App

Ứng dụng Flutter dùng để phân tích và quản lý dữ liệu XML bằng cấu trúc cây tổng quát (General Tree).

## Mô tả

Ứng dụng cho phép:

- Đọc và phân tích file XML
- Chuyển XML thành cấu trúc cây
- Hiển thị cây XML
- Tìm kiếm tag
- Tìm kiếm nội dung
- Chuyển đổi XML sang JSON
- Chuyển đổi JSON sang XML

Ứng dụng được xây dựng bằng Flutter và Dart.

# Công nghệ sử dụng

- Flutter
- Dart
- Package `xml`

---

# Cấu trúc dữ liệu

Ứng dụng sử dụng cấu trúc cây tổng quát:

```dart
class TreeNode {
  String tagName;
  String? text;

  List<TreeNode> children;
}
```

# Demo
<img width="120" height="262" alt="xml" src="https://github.com/user-attachments/assets/ceb95019-e665-4eac-aa5a-7db277c1edf2" />
