import 'dart:core';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:openscan/Utilities/constants.dart';
import 'package:openscan/Utilities/cropper.dart';
import 'package:openscan/screens/home_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';

class ScanDocument extends StatefulWidget {
  static String route = "ScanDocument";

  @override
  _ScanDocumentState createState() => _ScanDocumentState();
}

class _ScanDocumentState extends State<ScanDocument> {
  File imageFile;
  List<File> imageFiles = [];
  String appName = 'OpenScan';
  String appPath;
  String docPath;

  @override
  void initState() {
    super.initState();
    createDirectoryName();
    _createImage();
  }

  Future<String> getAppPath() async {
    final Directory _appDocDir = await getApplicationDocumentsDirectory();
    final Directory _appDocDirFolder =
        Directory('${_appDocDir.path}/$appName/');

    if (await _appDocDirFolder.exists()) {
      return _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      return _appDocDirNewFolder.path;
    }
  }

  Future<File> _openCamera() async {
    File image;
    final _picker = ImagePicker();
    var picture = await _picker.getImage(source: ImageSource.camera);
    if (picture != null) {
      final requiredPicture = File(picture.path);
      image = requiredPicture;
    }
    return image;
  }

  Future _createImage() async {
    File image = await _openCamera();
    if (image != null) {
      Cropper cropper = Cropper();
      var imageFile = await cropper.cropImage(image);
      if (imageFile != null)
        setState(() {
          imageFiles.add(imageFile);
        });
    }
  }

  Future<void> createDirectoryName() async {
    Directory appDir = await getExternalStorageDirectory();
    docPath = "${appDir.path}/OpenScan ${DateTime.now()}";
  }

  Future<void> _saveImage(File image, int i) async {
    if (await Directory(docPath).exists() != true) {
      new Directory(docPath).create();
    }

    File tempPic = File("$docPath/$i.png");
    image.copy(tempPic.path);
  }

  Future<void> _deleteTemporaryFiles() async {
    // Delete the temporary files created by the image_picker package
    Directory appDocDir = await getExternalStorageDirectory();
    String appDocPath = "${appDocDir.path}/Pictures/";
    Directory del = Directory(appDocPath);
    if (await del.exists()) {
      del.deleteSync(recursive: true);
    }
    new Directory(appDocPath).create();
  }

  Future<bool> _onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              // TODO: Do you want changes?
              title: Center(child: Text('Note')),
              contentPadding: EdgeInsets.fromLTRB(20, 40, 20, 30),
              content: Text(
                'Do you want to discard the documents?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              backgroundColor: primaryColor,
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.popUntil(
                      context, ModalRoute.withName(HomeScreen.route)),
                  child: Text('Yes'),
                ),
                FlatButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'No',
                  ),
                ),
              ],
            );
          },
        ) ??
        false);
  }

  void _removeImage(int index) {
    setState(() {
      imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: primaryColor,
            leading: IconButton(
              onPressed: _onBackPressed,
              icon: Icon(
                Icons.arrow_back_ios,
                color: secondaryColor,
              ),
            ),
            title: RichText(
              text: TextSpan(
                text: 'Scan ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                children: [
                  TextSpan(
                      text: 'Document', style: TextStyle(color: secondaryColor),),
                ],
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: ((imageFiles.length) / 2).round(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 3.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    RaisedButton(
                      elevation: 20,
                      color: primaryColor,
                      onPressed: () {},
                      child: FocusedMenuHolder(
                        menuWidth: size.width * 0.44,
                        onPressed: () {
                          showCupertinoDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  elevation: 20,
                                  backgroundColor: primaryColor,
                                  child: Container(
                                    width: size.width * 0.95,
                                    child: Image.file(imageFiles[index * 2]),
                                  ),
                                );
                              });
                        },
                        menuItems: [
                          FocusedMenuItem(
                            title: Text(
                              'Crop',
                              style: TextStyle(color: Colors.black),
                            ),
                            onPressed: () async {
                              Cropper cropper = Cropper();
                              var image = await cropper.cropImage(imageFiles[index * 2]);
                              imageFiles.removeAt(index * 2);
                              // TODO: Avoid change in order
                              setState(() {
                                imageFiles.add(image);
                              });
                            },
                          ),
                          FocusedMenuItem(
                              title: Text('Remove'),
                              // TODO : Alert Dialog confirmation
                              onPressed: () => _removeImage(index * 2),
                              backgroundColor: Colors.redAccent),
                        ],
                        child: Container(
                          child: Image.file(imageFiles[index * 2]),
                          height: size.height * 0.25,
                          width: size.width * 0.4,
                        ),
                      ),
                    ),
                    if (index * 2 + 1 < imageFiles.length)
                      RaisedButton(
                        elevation: 20,
                        color: primaryColor,
                        onPressed: () {},
                        child: FocusedMenuHolder(
                          menuWidth: size.width * 0.44,
                          onPressed: () {
                            showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    elevation: 20,
                                    backgroundColor: primaryColor,
                                    child: Container(
                                      width: size.width * 0.95,
                                      child: Image.file(imageFiles[index * 2 + 1]),
                                    ),
                                  );
                                });
                          },
                          menuItems: [
                            FocusedMenuItem(
                              title: Text(
                                'Crop',
                                style: TextStyle(color: Colors.black),
                              ),
                              onPressed: () async {
                                Cropper cropper = Cropper();
                                var image = await cropper.cropImage(imageFiles[index * 2 + 1]);
                                imageFiles.removeAt(index * 2 + 1);
                                // TODO: Avoid change in order
                                setState(() {
                                  imageFiles.add(image);
                                });
                              },
                            ),
                            FocusedMenuItem(
                                title: Text('Remove'),
                                // TODO : Alert Dialog confirmation
                                onPressed: () => _removeImage(index * 2),
                                backgroundColor: Colors.redAccent),
                          ],
                          child: Container(
                            child: Image.file(imageFiles[index * 2 + 1]),
                            height: size.height * 0.25,
                            width: size.width * 0.4,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: RaisedButton(
              onPressed: () async {
                if (imageFiles.length != 0) {
                  for (int i = 0; i < imageFiles.length; i++) {
                    await _saveImage(imageFiles[i], i + 1);
                  }
                }
                await _deleteTemporaryFiles();
                Navigator.pop(context, true);
              },
              color: secondaryColor,
              textColor: primaryColor,
              child: Container(
                alignment: Alignment.center,
                height: 55,
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: secondaryColor,
            onPressed: _createImage,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

