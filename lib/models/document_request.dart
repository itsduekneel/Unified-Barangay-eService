class DocumentRequest {
  final String id;
  final String title;
  final double amount;
  final bool isPublished;
  final int iconCode;
  final String? pdfName;
  final String? pdfUrl;
  final String status;
  final List<Map<String, dynamic>> formFields;

  const DocumentRequest({
    required this.id,
    required this.title,
    required this.amount,
    required this.isPublished,
    required this.iconCode,
    this.pdfName,
    this.pdfUrl,
    required this.status,
    required this.formFields,
  });

  factory DocumentRequest.fromMap(Map<String, dynamic> map) {
    return DocumentRequest(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      isPublished: map['is_published'] ?? false,
      iconCode: map['icon_code'] ?? 57701,
      pdfName: map['pdf_name'],
      pdfUrl: map['pdf_url'],
      status: map['status'] ?? 'pending',
      formFields: List<Map<String, dynamic>>.from(
        (map['form_fields'] as List? ?? []).map(
          (e) => Map<String, dynamic>.from(e as Map),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'amount': amount,
    'is_published': isPublished,
    'icon_code': iconCode,
    'pdf_name': pdfName,
    'pdf_url': pdfUrl,
    'status': status,
    'form_fields': formFields,
  };
}
