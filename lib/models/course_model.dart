class Course {
  final String title;
  final String ratingText; // cth: "4.9 (1.2k+ Siswa)"
  final String price;      // cth: "Rp 149.000"
  final String imageUrl;
  final String? badge;     // cth: "TERPOPULER"

  Course({
    required this.title,
    required this.ratingText,
    required this.price,
    required this.imageUrl,
    this.badge,
  });
}