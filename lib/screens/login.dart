import 'package:flutter/cupertino.dart';
import 'package:instapost/api/post_api.dart';
import 'package:instapost/api/user_api.dart';
import 'package:instapost/colors.dart';
import 'package:instapost/model/user.dart';
import 'package:instapost/notifier/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:instapost/widgets/post_widget.dart';
enum AuthMode { Signup, Login }

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = new TextEditingController();
  AuthMode _authMode = AuthMode.Login;

  User _user = User();

  @override
  void initState() {
    
    super.initState();
    //userList = [];
  }

  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    AuthNotifier authNotifier =
        Provider.of<AuthNotifier>(context, listen: false);

    if (_authMode == AuthMode.Login) {
      login(_user, authNotifier);
    } else {
      signup(_user, authNotifier);
    }
  }

  Widget _buildDisplayNameField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(CupertinoIcons.person),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: "Display Name",
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
      ),
      keyboardType: TextInputType.text,
      style: TextStyle(
        fontSize: 20,
      ),
      cursorColor: CupertinoColors.activeBlue,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Display Name is required';
        }

        if (value.length < 5 || value.length > 12) {
          return 'Display Name must be betweem 5 and 12 characters';
        }

        return null;
      },
      onSaved: (String value) {
        _user.displayName = value;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(CupertinoIcons.mail),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: "Email",
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
      ),
      keyboardType: TextInputType.emailAddress,
      //initialValue: 'julian@post.com',
      style: TextStyle(fontSize: 20),
      //cursorColor: white,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Email is required';
        }

        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }

        return null;
      },
      onSaved: (String value) {
        _user.email = value;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(CupertinoIcons.eye),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: "Password",
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
      ),
      style: TextStyle(fontSize: 20),
      //cursorColor: white,
      obscureText: true,
      controller: _passwordController,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Password is required';
        }

        if (value.length < 5 || value.length > 20) {
          return 'Password must be betweem 5 and 20 characters';
        }

        return null;
      },
      onSaved: (String value) {
        _user.password = value;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      decoration: InputDecoration(
        prefixIcon: Icon(CupertinoIcons.eye),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        labelText: "Confirm Password",
        labelStyle: TextStyle(color: CupertinoColors.systemGrey),
      ),
      style: TextStyle(fontSize: 20),
      //cursorColor: white,
      obscureText: true,
      validator: (String value) {
        if (_passwordController.text != value) {
          return 'Passwords do not match';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building login screen");

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Please Sign In",
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              //decoration: BoxDecoration(color: Color(0xff34056D)),
              child: Material(
                child: Form(
                  //autovalidate: true,
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 25),
                      _authMode == AuthMode.Signup
                          ? _buildDisplayNameField()
                          : Container(),
                      SizedBox(height: 16),
                      _buildEmailField(),
                      SizedBox(height: 16),
                      _buildPasswordField(),
                      SizedBox(height: 16),
                      _authMode == AuthMode.Signup
                          ? _buildConfirmPasswordField()
                          : Container(),
                      SizedBox(height: 20),
                      CupertinoButton(
                          // padding: EdgeInsets.symmetric(horizontal: 30),
                          color: CupertinoColors.activeGreen,
                          borderRadius: BorderRadius.circular(25),
                          child: Text(
                            _authMode == AuthMode.Login ? 'Login' : 'Signup',
                            style: TextStyle(
                                fontSize: 20,
                                color: white,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _submitForm()),
                      SizedBox(height: 20),
                      CupertinoButton(
                           padding: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(25),
                          child: Text(
                            'Switch to ${_authMode == AuthMode.Login ? 'Signup' : 'Login'}',
                            style: TextStyle(fontSize: 20, color: white),
                          ),
                          onPressed: () {
                            setState(() {
                              _authMode = _authMode == AuthMode.Login
                                  ? AuthMode.Signup
                                  : AuthMode.Login;
                            });
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
