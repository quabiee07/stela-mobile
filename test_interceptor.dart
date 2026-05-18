import 'dart:convert';
import 'dart:typed_data';
void main() {
  final encoder = JsonEncoder.withIndent('  ');
  try {
    encoder.convert(Uint8List.fromList([1, 2, 3]));
  } catch (e) {
    print("Error: $e");
  }
}
