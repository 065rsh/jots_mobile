class User {
  String userId;
  dynamic allTagsArr;

  // User(String userId){
  //   this.userId = userId;
  // }

  setAllTagsArr(dynamic allTagsArr) {
    this.allTagsArr = allTagsArr;
  }

  List<String> getAllTagsArr() {
    return this.allTagsArr;
  }
}
