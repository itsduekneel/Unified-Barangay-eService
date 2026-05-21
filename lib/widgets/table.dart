import 'package:flutter/material.dart';

// --- DATA MODEL ---
class Data {
  final String? userId,
      firstName,
      middleName,
      lastName,
      sex,
      birthday,
      civilStatus,
      contactNo,
      residency,
      houseNo,
      street,
      purok,
      dateReg;

  Data({
    this.userId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.sex,
    this.birthday,
    this.civilStatus,
    this.contactNo,
    this.residency,
    this.houseNo,
    this.street,
    this.purok,
    this.dateReg,
  });

  List<String> toRow() => [
    userId ?? '',
    firstName ?? '',
    middleName ?? '',
    lastName ?? '',
    sex ?? '',
    birthday ?? '',
    civilStatus ?? '',
    contactNo ?? '',
    residency ?? '',
    houseNo ?? '',
    street ?? '',
    purok ?? '',
    dateReg ?? '',
  ];

  static const List<String> labels = [
    "UserId",
    "First Name",
    "Middle Name",
    "Last Name",
    "Sex",
    "Birthday",
    "Civil Status",
    "Contact No.",
    "Residency",
    "House No.",
    "Street",
    "Purok",
    "Date Registered",
  ];
  static const List<double> widths = [
    100,
    120,
    120,
    120,
    60,
    110,
    110,
    130,
    110,
    90,
    130,
    90,
    130,
  ];
}

// --- TABLE WIDGET ---
class UserTable extends StatelessWidget {
  final List<Data> items;
  final List<String> columnLabels;
  final List<double> columnWidths;

  const UserTable({
    super.key,
    required this.items,
    required this.columnLabels,
    required this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    final double totalWidth = columnWidths.reduce((a, b) => a + b);

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: totalWidth,
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFF8B2CF5),
                    height: 50,
                    child: Row(
                      children: List.generate(
                        columnLabels.length,
                        (i) =>
                            _buildCell(columnLabels[i], columnWidths[i], true),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final rowData = items[index].toRow();
                        return Container(
                          color: index % 2 == 0
                              ? Colors.white
                              : const Color(0xFFF7F2FF),
                          height: 50,
                          child: Row(
                            children: List.generate(
                              rowData.length,
                              (colIndex) => _buildCell(
                                rowData[colIndex],
                                columnWidths[colIndex],
                                false,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, double width, bool isHeader) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? Colors.white : Colors.black87,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
