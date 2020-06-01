class ImagePath {

  // declaring image paths
  static ImagePath _instance = ImagePath._init();
  static ImagePath get instance => _instance;
  ImagePath._init();

  String get notFoundLottie => lottiePath("shopbag");

  String lottiePath(String text) => "assets/lottie/$text.json";

  //can be downloaded as assets
  String welcomeBackgroundNetwork = 'https://i.picsum.photos/id/1/450/800.jpg?blur=5';

  String dashboardBackgroundNetwork = 'https://i.picsum.photos/id/1031/450/800.jpg?blur=5';

  String profileInitialNetwork='https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR8QMTmCUwPeDMiZ0pZFQqQkHCQvcWY7ECb_Lcfc4QqqS2PL9rb&usqp=CAU';

}
