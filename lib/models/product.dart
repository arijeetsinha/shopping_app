class Product {
  final int id;
  final String title;
  final String desc;
  final double price;
  final String category;
  final String image;
  final List fav = [
    '',
  ];

  Product({
    this.id = 0,
    this.title = '',
    this.desc = '',
    this.price = 0.0,
    this.category = ' ',
    this.image = '',
  });
}
