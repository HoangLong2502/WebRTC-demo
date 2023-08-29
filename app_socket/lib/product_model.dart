// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

ProductModel productModelFromJson(String str) => ProductModel.fromJson(json.decode(str));

String productModelToJson(ProductModel data) => json.encode(data.toJson());

class ProductModel {
    final int? id;
    final String? title;
    final List<int>? images;
    final List<ImagesDatum>? imagesData;
    final String? description;
    final double? priceSell;
    final int? category;
    final CategoryData? categoryData;
    final int? userCreated;
    final UserCreatedData? userCreatedData;
    final DateTime? createdAt;
    final dynamic updatedAt;

    ProductModel({
        this.id,
        this.title,
        this.images,
        this.imagesData,
        this.description,
        this.priceSell,
        this.category,
        this.categoryData,
        this.userCreated,
        this.userCreatedData,
        this.createdAt,
        this.updatedAt,
    });

    ProductModel copyWith({
        int? id,
        String? title,
        List<int>? images,
        List<ImagesDatum>? imagesData,
        String? description,
        double? priceSell,
        int? category,
        CategoryData? categoryData,
        int? userCreated,
        UserCreatedData? userCreatedData,
        DateTime? createdAt,
        dynamic updatedAt,
    }) => 
        ProductModel(
            id: id ?? this.id,
            title: title ?? this.title,
            images: images ?? this.images,
            imagesData: imagesData ?? this.imagesData,
            description: description ?? this.description,
            priceSell: priceSell ?? this.priceSell,
            category: category ?? this.category,
            categoryData: categoryData ?? this.categoryData,
            userCreated: userCreated ?? this.userCreated,
            userCreatedData: userCreatedData ?? this.userCreatedData,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
        );

    factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"],
        title: json["title"],
        images: json["images"] == null ? [] : List<int>.from(json["images"]!.map((x) => x)),
        imagesData: json["images_data"] == null ? [] : List<ImagesDatum>.from(json["images_data"]!.map((x) => ImagesDatum.fromJson(x))),
        description: json["description"],
        priceSell: json["price_sell"],
        category: json["category"],
        categoryData: json["category_data"] == null ? null : CategoryData.fromJson(json["category_data"]),
        userCreated: json["user_created"],
        userCreatedData: json["user_created_data"] == null ? null : UserCreatedData.fromJson(json["user_created_data"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "images_data": imagesData == null ? [] : List<dynamic>.from(imagesData!.map((x) => x.toJson())),
        "description": description,
        "price_sell": priceSell,
        "category": category,
        "category_data": categoryData?.toJson(),
        "user_created": userCreated,
        "user_created_data": userCreatedData?.toJson(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt,
    };
}

class CategoryData {
    final int? id;
    final String? title;

    CategoryData({
        this.id,
        this.title,
    });

    CategoryData copyWith({
        int? id,
        String? title,
    }) => 
        CategoryData(
            id: id ?? this.id,
            title: title ?? this.title,
        );

    factory CategoryData.fromJson(Map<String, dynamic> json) => CategoryData(
        id: json["id"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
    };
}

class ImagesDatum {
    final int? id;
    final String? image;

    ImagesDatum({
        this.id,
        this.image,
    });

    ImagesDatum copyWith({
        int? id,
        String? image,
    }) => 
        ImagesDatum(
            id: id ?? this.id,
            image: image ?? this.image,
        );

    factory ImagesDatum.fromJson(Map<String, dynamic> json) => ImagesDatum(
        id: json["id"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
    };
}

class UserCreatedData {
    final int? id;
    final String? phone;
    final dynamic fullName;
    final dynamic email;
    final DateTime? createdAt;

    UserCreatedData({
        this.id,
        this.phone,
        this.fullName,
        this.email,
        this.createdAt,
    });

    UserCreatedData copyWith({
        int? id,
        String? phone,
        dynamic fullName,
        dynamic email,
        DateTime? createdAt,
    }) => 
        UserCreatedData(
            id: id ?? this.id,
            phone: phone ?? this.phone,
            fullName: fullName ?? this.fullName,
            email: email ?? this.email,
            createdAt: createdAt ?? this.createdAt,
        );

    factory UserCreatedData.fromJson(Map<String, dynamic> json) => UserCreatedData(
        id: json["id"],
        phone: json["phone"],
        fullName: json["full_name"],
        email: json["email"],
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "phone": phone,
        "full_name": fullName,
        "email": email,
        "created_at": createdAt?.toIso8601String(),
    };
}
