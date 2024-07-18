import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:compass_model/model.dart';

final _continents = [
  Continent(
    name: 'Europe',
    imageUrl: 'https://rstr.in/google/tripedia/TmR12QdlVTT',
  ),
  Continent(
    name: 'Asia',
    imageUrl: 'https://rstr.in/google/tripedia/VJ8BXlQg8O1',
  ),
  Continent(
    name: 'South America',
    imageUrl: 'https://rstr.in/google/tripedia/flm_-o1aI8e',
  ),
  Continent(
    name: 'Africa',
    imageUrl: 'https://rstr.in/google/tripedia/-nzi8yFOBpF',
  ),
  Continent(
    name: 'North America',
    imageUrl: 'https://rstr.in/google/tripedia/jlbgFDrSUVE',
  ),
  Continent(
    name: 'Oceania',
    imageUrl: 'https://rstr.in/google/tripedia/vxyrDE-fZVL',
  ),
  Continent(
    name: 'Australia',
    imageUrl: 'https://rstr.in/google/tripedia/z6vy6HeRyvZ',
  ),
];

Response continentHandler(Request req) {
  return Response.ok(jsonEncode(_continents));
}
