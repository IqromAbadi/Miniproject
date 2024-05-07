import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomeController extends GetxController {
  final name = ''.obs;
  final address = ''.obs;
  final phone = ''.obs;
  RxString imageUrl = ''.obs;
  late String userId;
  final ImagePicker _picker = ImagePicker();
  late File _image;

  @override
  void onInit() {
    super.onInit();
    fetchUserId();
  }

  Future<void> fetchUserId() async {
    userId = FirebaseAuth.instance.currentUser!.uid;
    await fetchData(userId);
  }

  Future<void> fetchData(String userId) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        name.value = userData['name'] ?? '';
        address.value = userData['address'] ?? '';
        phone.value = userData['phone'] ?? '';
        imageUrl.value = userData['imageUrl'] ?? '';
      } else {
        name.value = '';
        address.value = '';
        phone.value = '';
        imageUrl.value = '';
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> getImageAndUpload() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      await uploadImageToFirebase(_image);
    } else {
      print('No image selected.');
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final fileName = 'user_$userId.jpg';
      final firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('images')
          .child(fileName);

      final firebase_storage.UploadTask uploadTask = ref.putFile(image);

      await uploadTask.whenComplete(() async {
        final url = await ref.getDownloadURL();
        imageUrl.value = url;

        await FirebaseFirestore.instance.collection('User').doc(userId).update({
          'imageUrl': url,
        });

        update();
      });
    } catch (e) {
      print('Error uploading image to Firebase: $e');
    }
  }
}
