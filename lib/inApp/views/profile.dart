import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_image_constants.dart';
import '../../core/init/locale_keys.g.dart';
import '../../core/init/string_extensions.dart';
import '../../core/language/appLanguages.dart';
import '../../core/theme/appThemes.dart';
import '../../core/theme/themeManager.dart';
import '../../core/view/base/base_state.dart';
import '../../core/view/widget/loading/loading.dart';
import '../models/user.dart';
import '../services/auth.dart';
import '../services/database_user.dart';

class Profile extends StatefulWidget {
  Profile({Key key, @required this.userUid}) : super(key: key);
  final userUid;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends BaseState<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKeyProfile =
      new GlobalKey<ScaffoldState>();

  final _auth = AuthService();

  final _profileFormKey = GlobalKey<FormState>();

  bool _themeValue = false;
  bool _languageValue = false;

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userImageController = TextEditingController();

  User user;
  File _image;

  @override
  void dispose() {
    _nameController.dispose();
    _userImageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    loadLanguage() async {
      await SharedPreferences.getInstance().then((prefs) {
        int preferredLanguage = prefs.getInt('language_preference') ?? 0;
        if (preferredLanguage == 0) {
          setState(() {
            _languageValue = false;
          });
        } else {
          setState(() {
            _languageValue = true;
          });
        }
      });
    }

    loadTheme() async {
      await SharedPreferences.getInstance().then((prefs) {
        int preferredTheme = prefs.getInt('theme_preference') ?? 0;
        if (preferredTheme == 0) {
          setState(() {
            _themeValue = false;
          });
        } else {
          setState(() {
            _themeValue = true;
          });
        }
      });
    }

    Future getUser() async {
      var currentUser = await DatabaseUserService().getProfile(widget.userUid);
      setState(() {
        user = currentUser;
        _nameController.text = currentUser.name;
        _userImageController.text = currentUser.userImage ?? '';
      });
    }

    loadLanguage();
    loadTheme();
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeManager _themeChanger = Provider.of<ThemeManager>(context);

    Future getImage() async {
      var image = await ImagePicker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        _image = image;
      });
    }

    setLanguage(AppLanguage language) async {
      var prefs = await SharedPreferences.getInstance();
      prefs.setInt('language_preference', AppLanguage.values.indexOf(language));
    }

    Future uploadPic(BuildContext context) async {
      String fileName = basename(_image.path);
      StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(fileName);

      StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
      var url = await (await uploadTask.onComplete).ref.getDownloadURL();
      _userImageController.text = url.toString();

      _scaffoldKeyProfile.currentState.showSnackBar(SnackBar(
          content: Text(LocaleKeys.appStrings_profilePicUpload.locale)));
    }

    return loading
        ? Loading()
        : Scaffold(
            key: _scaffoldKeyProfile,
            appBar: AppBar(
              title: Text(LocaleKeys.appStrings_profile.locale),
              actions: <Widget>[
                FlatButton(
                  color: Colors.transparent,
                  onPressed: () async {
                    await _auth.signOut();
                    //Navigator.pushNamedAndRemoveUntil( context, '/welcome', ModalRoute.withName('/'), arguments:{ }) → Future //isimlendirilmiş sayfayı ekrana bas ve geçmiş sayfalardan verilen sayfaya değin tüm geçmişi sayfaları sil(ModalRoute Geçmiş sayfaları tutan modelrota)
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/welcome',
                      ModalRoute.withName('/'),
                    );
                  },
                  child: Text(
                    LocaleKeys.appStrings_signOut.locale,
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ],
            ),
            body: Builder(
              builder: (context) => SingleChildScrollView(
                child: Form(
                  key: _profileFormKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(LocaleKeys
                                    .appStrings_darkModeSwitch.locale),
                                Center(
                                  child: Switch(
                                    onChanged: (bool value) {
                                      setState(() {
                                        this._themeValue = value;
                                      });
                                      if (_themeValue) {
                                        _themeChanger.setTheme(AppTheme.Dark);
                                      } else {
                                        _themeChanger.setTheme(AppTheme.White);
                                      }
                                    },
                                    value: _themeValue,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(LocaleKeys
                                    .appStrings_languageSwitch.locale),
                                Center(
                                  child: Switch(
                                    onChanged: (bool value) {
                                      setState(() {
                                        this._languageValue = value;
                                      });
                                      if (_languageValue) {
                                        context.locale = AppConstants.TR_LOCALE;
                                        setLanguage(AppLanguage.Turkish);
                                      } else {
                                        context.locale = AppConstants.EN_LOCALE;
                                        setLanguage(AppLanguage.English);
                                      }
                                    },
                                    value: _languageValue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        TextFormField(
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText: LocaleKeys.appStrings_name.locale),
                          controller: _nameController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocaleKeys.appStrings_enterName.locale;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: dynamicHeight(0.01),
                        ),
                        TextFormField(
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText: LocaleKeys.appStrings_password.locale),
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value.isEmpty) {
                              return LocaleKeys.appStrings_enterPassword.locale;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: dynamicHeight(0.01),
                        ),
                        TextFormField(
                          decoration: appConstants.textInputDecoration.copyWith(
                              labelText:
                                  LocaleKeys.appStrings_confirmPassword.locale),
                          obscureText: true,
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return LocaleKeys
                                  .appStrings_confirmPasswordMatch.locale;
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: dynamicHeight(0.02),
                        ),
                        CircleAvatar(
                          radius: dynamicWidth(0.3),
                          backgroundColor: currentTheme.primaryColorLight,
                          child: ClipOval(
                            child: new SizedBox(
                              width: dynamicWidth(0.5),
                              height: dynamicWidth(0.5),
                              child: (_image != null)
                                  ? Image.file(
                                      _image,
                                      fit: BoxFit.fill,
                                    )
                                  : (_userImageController.text != '')
                                      ? Image.network(
                                          _userImageController.text,
                                          fit: BoxFit.fill,
                                        )
                                      : Image.network(
                                          ImagePath
                                              .instance.profileInitialNetwork,
                                          fit: BoxFit.fill,
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: dynamicHeight(0.02),
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.camera,
                              size: 30.0,
                            ),
                            onPressed: () {
                              getImage();
                            }),
                        SizedBox(
                          height: dynamicHeight(0.02),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              elevation: 4.0,
                              splashColor: Colors.blueGrey,
                              child: Text(
                                LocaleKeys.appStrings_cancel.locale,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                            ),
                            RaisedButton(
                              color: Theme.of(context).primaryColorDark,
                              onPressed: () {
                                uploadPic(context);
                              },
                              elevation: 4.0,
                              splashColor: Colors.blueGrey,
                              child: Text(
                                LocaleKeys.appStrings_uploadPicture.locale,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16.0),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin:
                              const EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: RaisedButton(
                              child: Text(LocaleKeys.appStrings_update.locale),
                              color: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              onPressed: () async {
                                if (_profileFormKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  try {
                                    await DatabaseUserService(uid: widget.userUid)
                                        .editProfile(
                                      widget.userUid,
                                      _nameController.text,
                                      _userImageController.text,
                                    );

                                    if (_passwordController.text.isNotEmpty) {
                                      FirebaseUser updatedUser =
                                          await FirebaseAuth.instance
                                              .currentUser();
                                      updatedUser
                                          .updatePassword(
                                              _passwordController.text)
                                          .then((_) {
                                        //getUser();
                                      }).catchError((e) {});
                                    }
                                    setState(() {
                                      error = LocaleKeys
                                          .appStrings_profileUpdated.locale;
                                      loading = false;
                                    });
                                    //Navigator.pop(context);
                                  } catch (e) {
                                    setState(
                                      () {
                                        error = LocaleKeys
                                            .appStrings_errorCYI.locale;
                                        loading = false;
                                      },
                                    );
                                  }
                                }
                              }),
                        ),
                        SizedBox(
                          height: dynamicHeight(0.04),
                        ),
                        Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                        ),

                        /*Container(
                          child: Column(
                            children: <Widget>[
                              FlatButton(
                                  child: Text('Dark Theme'),
                                  onPressed: () =>
                                      _themeChanger.setTheme(myThemeDark)),
                              FlatButton(
                                  child: Text('Light Theme'),
                                  onPressed: () => _themeChanger
                                      .setTheme(myTheme)),
                            ],
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
