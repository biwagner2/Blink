import 'dart:typed_data';

class BioPicture{
    late int id; //unique to each picture
    late int userId;
    late Uint8List bioPictureData;

  int getId()
  {
    return id;
  }
  int getUserId()
  {
    return userId;
  }
}