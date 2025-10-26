// lib/product.dart

class Product {
  final String name;
  final String price;
  final String description;

  Product({required this.name, required this.price, required this.description});
}

final List<Product> products = [
  Product(name: 'Udang Kupas', price: 'Harga menyusul', description: 'Udang kupas segar dan berkualitas.'),
  Product(name: 'Cumi Tube/Cumi Ring', price: 'Harga menyusul', description: 'Cumi tube dan cumi ring siap olah.'),
  Product(name: 'Ikan Nila', price: 'Harga menyusul', description: 'Ikan nila segar langsung dari peternak.'),
  Product(name: 'Ikan Dori', price: 'Harga menyusul', description: 'Ikan dori fillet premium.'),
];