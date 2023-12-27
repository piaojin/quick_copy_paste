enum ClipboardItemType {
  text, image, file
}

class ClipboardItem {
  int index = -1;
  String? text;
  ClipboardItemType type = ClipboardItemType.text;

  ClipboardItem(this.text);
}
