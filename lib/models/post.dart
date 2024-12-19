class Post{
  int id;
  int userId;
  String title;
  String body;

  Post(this.id, this.userId, this.title, this.body);

  factory Post.fromJson(Map json){
    return Post(
      json["id"],
      json["userId"],
      json["title"],
      json["body"]
    );
  }

}