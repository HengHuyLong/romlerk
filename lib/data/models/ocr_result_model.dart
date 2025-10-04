class OcrResult {
  final String? fullText;

  OcrResult({this.fullText});

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    final responses = json["responses"] as List?;
    if (responses == null || responses.isEmpty) {
      return OcrResult(fullText: null);
    }

    final fullText = responses[0]["fullTextAnnotation"]?["text"];
    return OcrResult(fullText: fullText);
  }
}
