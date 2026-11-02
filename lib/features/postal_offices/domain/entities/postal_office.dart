import 'package:equatable/equatable.dart';

class PostalCity extends Equatable {
  const PostalCity({required this.id, required this.name});
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

class PostalProvince extends Equatable {
  PostalProvince({
    required this.id,
    required this.name,
    required Iterable<PostalCity> cities,
  }) : cities = List.unmodifiable(cities);
  final String id;
  final String name;
  final List<PostalCity> cities;
  @override
  List<Object?> get props => [id, name, cities];
}

class PostalOffice extends Equatable {
  const PostalOffice({required this.id, required this.address});
  final String id;
  final String address;
  @override
  List<Object?> get props => [id, address];
}
