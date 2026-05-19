class Book {
  final int bid;
  final String title;
  final String author;
  final String genre;
  final double price;
  final int ratings;
  final String description;
  final String coverUrl;
  final int stock;
  final bool isBestseller;
  final DateTime releaseDate;

  Book({
    required this.bid,
    required this.title,
    required this.author,
    required this.genre,
    required this.price,
    required this.ratings,
    required this.description,
    required this.coverUrl,
    required this.stock,
    required this.isBestseller,
    required this.releaseDate,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bid: json['bid'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      genre: json['genre'] ?? 'General',

      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      ratings: json['ratings'] ?? 0,
      description: json['description'] ?? '',
      coverUrl: json['coverUrl'] ?? 'https://via.placeholder.com/150',
      stock: json['stock'] ?? 0,
      isBestseller: json['isBestseller'] ?? false,
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : DateTime.now(),
    );
  }
}