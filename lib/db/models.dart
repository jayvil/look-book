// https://itnext.io/how-to-use-flutter-with-sqlite-b6c75a5215c4

abstract class DatabaseTable {
  late int? id;
  static fromMap() {}
  Map<String, dynamic> toMap();
  @override
  String toString();
}

// class Wardrobe extends DatabaseTable {
//   static String tableName = 'wardrobe';
//
//
//   /* Wardrobe */
//
//   Wardrobe({
//
//   });
//
//   static Wardrobe fromMap(Map<String, dynamic> map) {
//     // TODO null checks
//     return Wardrobe(
//
//     );
//   }
//
//   // Convert a Class into a Map. The keys must correspond to the names of the
//   // columns in the database.
//   @override
//   Map<String, dynamic> toMap() {
//     return {
//
//     };
//   }
//
//   @override
//   String toString() {
//     return '''
//
//     ''';
//   }
// }

/* Clothing Items */

class ClothingItem extends DatabaseTable {
  static String tableName = 'clothing_item';
  final int subtype_id;
  final int type_id;
  final String image_url;
  final String image_path;
  final String tags;
  final int is_archived;
  final String materials;
  final String colors;
  final int creation_datetime;
  final String patterns;
  final String brand;
  final String purchase_date;
  final double price;
  final String shop_link;
  final int is_spring;
  final int is_summer;
  final int is_fall;
  final int is_winter;
  final int is_available;
  final String size;
  final String note;

  ClothingItem({
    required this.subtype_id,
    required this.type_id,
    required this.image_path,
    required this.image_url,
    required this.tags,
    required this.is_archived,
    required this.materials,
    required this.colors,
    required this.creation_datetime,
    required this.patterns,
    required this.brand,
    required this.purchase_date,
    required this.price,
    required this.shop_link,
    required this.is_spring,
    required this.is_summer,
    required this.is_fall,
    required this.is_winter,
    required this.is_available,
    required this.size,
    required this.note,
});

  static ClothingItem fromMap(Map<String, dynamic> map) {
    // TODO null checks ?
    return ClothingItem(
      type_id: map['type_id'],
      subtype_id: map['subtype_id'],
      image_path: map['image_path'],
      image_url: map['image_url'],
      is_archived: map['is_archived'],
      creation_datetime: map['creation_datetime'],
      tags: map['tags'],
      colors: map['colors'],
      materials: map['materials'],
      patterns: map['patterns'],
      brand: map['brand'],
      price: map['price'],
      purchase_date: map['purchase_date'],
      shop_link: map['shop_link'],
      is_spring: map['is_spring'],
      is_summer: map['is_summer'],
      is_fall: map['is_fall'],
      is_winter: map['is_winter'],
      is_available: map['is_available'],
      size: map['size'],
      note: map['note'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    return {
      'type_id': type_id,
      'subtype_id': subtype_id,
      'image_path': image_path,
      'image_url': image_url,
      'tags': tags,
      'is_archived': is_archived,
      'creation_datetime': creation_datetime,
      'colors': colors,
      'materials': materials,
      'patterns': patterns,
      'brand': brand,
      'price': price,
      'purchase_date': purchase_date,
      'shop_link': shop_link,
      'is_spring': is_spring,
      'is_summer': is_summer,
      'is_fall': is_fall,
      'is_winter': is_winter,
      'is_available': is_available,
      'size': size,
      'note': note,
    };
  }

@override
String toString() {
return '''
    ClothingItem {
      type_id: $type_id,
      subtype_id: $subtype_id,
      image_path: $image_path,
      image_url: $image_url,
      tags: $tags
      is_archived: $is_archived,
      creation_datetime: $creation_datetime,
      colors: $colors,
      materials: $materials,
      patterns: $patterns,
      brand: $brand,
      price: $price,
      purchase_date: $purchase_date,
      shop_link: $shop_link,
      is_spring: $is_spring,
      is_summer: $is_summer,
      is_fall: $is_fall,
      is_winter: $is_winter,
      is_available: $is_available,
      size: $size,
      note: $note,
    }
    ''';
}

}

/* Clothing Types */

class ClothingTypes extends DatabaseTable {
  static String tableName = 'clothing_types';
  @override
  final int id;
  final String type_name;

  ClothingTypes({
    required this.id,
    required this.type_name,
  });

  static ClothingTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return ClothingTypes(
      id: map['id'],
      type_name: map['type_name'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type_name': type_name,
    };
  }

  @override
  String toString() {
    return '''
    ClothingTypes {
      id: $id,
      type_name: $type_name
    }
    ''';
  }
}

/* Clothing Sub Types */

class ClothingSubTypes extends DatabaseTable {
  static String tableName = 'clothing_sub_types';
  @override
  final int id;
  final int type_id;
  final String sub_type_name;
  final String description;

  ClothingSubTypes({
    required this.id,
    required this.type_id,
    required this.sub_type_name,
    required this.description,
  });

  static ClothingSubTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return ClothingSubTypes(
      id: map['id'],
      type_id: map['type_id'],
      sub_type_name: map['sub_type_name'],
      description: map['description'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type_id': type_id,
      'sub_type_name': sub_type_name,
      'description': description,
    };
  }

  @override
  String toString() {
    return '''
    ClothingSubTypes {
      id: $id,
      type_id: $type_id,
      sub_type_name: $sub_type_name,
      description: $description,
    }
    ''';
  }
}

/* Colors */
class ColorTypes extends DatabaseTable {
  @override
  final int id;
  final String color_name;

  ColorTypes({required this.id, required this.color_name});

  static ColorTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return ColorTypes(
      id: map['id'],
      color_name: map['color_name'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'color_name': color_name,
    };
  }

  @override
  String toString() {
    return '''
    Colors {
      id: $id,
      color_name: $color_name,
    }
    ''';
  }
}

/* Patterns */
class PatternTypes extends DatabaseTable {
  @override
  final int id;
  final String pattern_name;

  PatternTypes({required this.id, required this.pattern_name});

  static PatternTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return PatternTypes(
      id: map['id'],
      pattern_name: map['pattern_name'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pattern_name': pattern_name,
    };
  }

  @override
  String toString() {
    return '''
    Colors {
      id: $id,
      pattern_name: $pattern_name,
    }
    ''';
  }
}

/* Materials */
class MaterialTypes extends DatabaseTable {
  @override
  final int id;
  final String material_name;

  MaterialTypes({required this.id, required this.material_name});

  static MaterialTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return MaterialTypes(
      id: map['id'],
      material_name: map['material_name'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'material_name': material_name,
    };
  }

  @override
  String toString() {
    return '''
    Colors {
      id: $id,
      material_name: $material_name,
    }
    ''';
  }
}

/* Patterns */
class BrandTypes extends DatabaseTable {
  @override
  final int id;
  final String brand_name;

  BrandTypes({required this.id, required this.brand_name});

  static BrandTypes fromMap(Map<String, dynamic> map) {
    // TODO null checks
    return BrandTypes(
      id: map['id'],
      brand_name: map['brand_name'],
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand_name': brand_name,
    };
  }

  @override
  String toString() {
    return '''
    Colors {
      id: $id,
      brand_name: $brand_name,
    }
    ''';
  }
}
