class Competition {
  final String title;
  final String month;      // cth: "MAR"
  final String date;       // cth: "14"
  final String category;   // cth: "MAHASISWA"
  final String prizeInfo;  // cth: "Prize: Rp 25.000.000"
  final String imageUrl;

  Competition({
    required this.title,
    required this.month,
    required this.date,
    required this.category,
    required this.prizeInfo,
    required this.imageUrl,
  });
}