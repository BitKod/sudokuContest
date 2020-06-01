import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_image_constants.dart';
import '../../core/init/locale_keys.g.dart';
import '../../core/init/string_extensions.dart';
import '../../core/view/base/base_state.dart';
import '../../core/view/widget/card/text_input_card.dart';
import '../../core/view/widget/loading/loading.dart';
import '../services/auth.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WelcomeState();
}

class _WelcomeState extends BaseState<Welcome> {
  final AuthService _auth = AuthService();
  final _loginFormKey = GlobalKey<FormState>();
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();

  final _registerFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailRegisterController = TextEditingController();
  final _passwordRegisterController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: currentTheme.primaryColorLight,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: dynamicHeight(0.2),
            flexibleSpace: _getSpaceBar(),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: _getSliverBody(),
          ),
        ],
      ),
    );
  }

  Widget _getSpaceBar() {
    return FlexibleSpaceBar(
      centerTitle: true,
      titlePadding: EdgeInsets.only(
        left: dynamicWidth(0.02),
        right: dynamicWidth(0.02),
        top: dynamicHeight(0.01),
        bottom: dynamicHeight(0.01),
      ),
      title: Text(
        LocaleKeys.appStrings_welcomeTitle.locale,
        textAlign: TextAlign.center,
      ),
      background: Image.network(
        ImagePath.instance.welcomeBackgroundNetwork,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _getSliverBody() {
    final _kTabs = <Tab>[
      Tab(icon: Icon(Icons.save), text: LocaleKeys.appStrings_register.locale),
      Tab(icon: Icon(Icons.input), text: LocaleKeys.appStrings_login.locale),
    ];

    final _kTabPages = <Widget>[
      _signUpTab(),
      _logInTab(),
    ];

    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        backgroundColor: currentTheme.primaryColorLight,
        appBar: TabBar(
          labelColor: Colors.blueGrey[800],
          unselectedLabelColor: Colors.blueGrey[200],
          indicatorColor: Colors.red,
          tabs: _kTabs,
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }

  _logInTab() {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _loginFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_email.locale),
                        controller: _emailLoginController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterEmail.locale;
                          } else if (!EmailValidator.validate(value)) {
                            return LocaleKeys.appStrings_enterValidEmail.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_password.locale),
                        obscureText: true,
                        controller: _passwordLoginController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterPassword.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: RaisedButton(
                        child: Text(LocaleKeys.appStrings_login.locale),
                        color: currentTheme.primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (_loginFormKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              dynamic result =
                                  await _auth.logInWithEmailAndPassword(
                                      _emailLoginController.text,
                                      _passwordLoginController.text);
                              if (result != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/dashboard');
                              } else {
                                setState(() => error =
                                    LocaleKeys.appStrings_errorCYI.locale);
                                setState(() => loading = false);
                              }
                            } catch (e) {}
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  _signUpTab() {
    return loading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _registerFormKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    TextInputCard(
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
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_email.locale),
                        controller: _emailRegisterController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterEmail.locale;
                          } else if (!EmailValidator.validate(value)) {
                            return LocaleKeys.appStrings_enterValidEmail.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText: LocaleKeys.appStrings_password.locale),
                        obscureText: true,
                        controller: _passwordRegisterController,
                        validator: (value) {
                          if (value.isEmpty) {
                            return LocaleKeys.appStrings_enterPassword.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    TextInputCard(
                      TextFormField(
                        decoration: appConstants.textInputDecoration.copyWith(
                            labelText:
                                LocaleKeys.appStrings_confirmPassword.locale),
                        obscureText: true,
                        controller: _confirmPasswordController,
                        validator: (value) {
                          if (value != _passwordRegisterController.text) {
                            return LocaleKeys
                                .appStrings_confirmPasswordMatch.locale;
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                      child: RaisedButton(
                        child: Text(LocaleKeys.appStrings_register.locale),
                        color: currentTheme.primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          if (_registerFormKey.currentState.validate()) {
                            setState(() => loading = true);
                            try {
                              dynamic result =
                                  await _auth.registerWithEmailAndPassword(
                                      _nameController.text,
                                      _emailRegisterController.text,
                                      _passwordRegisterController.text);
                              if (result != null) {
                                Navigator.pushReplacementNamed(
                                    context, '/dashboard');
                              } else {
                                setState(() => error =
                                    LocaleKeys.appStrings_errorCYI.locale);
                                setState(() => loading = false);
                              }
                            } catch (e) {
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
