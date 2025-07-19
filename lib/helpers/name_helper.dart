class NameHelper {
  static String truncateName(String name) {
    if (name.length <= 15) return name;

    // Find the last space before or at position 15
    int lastSpace = name.substring(0, 15).lastIndexOf(' ');
    if (lastSpace == -1) {
      // If no space found, just take first 15 characters
      return name.substring(0, 15);
    }
    // Return everything up to the last space
    return name.substring(0, lastSpace);
  }
}
