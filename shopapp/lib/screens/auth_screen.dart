import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/models/http_exception.dart';
import 'package:shopapp/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});
  static const routeName = '/auth';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 118, 117, 1).withOpacity(0.9)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(
                        bottom: 20,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 94,
                      ),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Text(
                        'My Shop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      flex: deviceSize.width > 600 ? 2 : 1, child: AuthCard())
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({super.key});

  @override
  State<AuthCard> createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  final _passwordController = TextEditingController();

  var _isLoading = false;

  void _switchMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  void _showDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text(
                'An error Occured',
                style: TextStyle(color: Colors.black),
              ),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
              ],
            ));
  }

  void _submit() async {
    final _isvalid = _formKey.currentState!.validate();
    if (!_isvalid) {
      return;
    }
    _formKey.currentState?.save();
    setState(
      () {
        _isLoading = true;
      },
    );
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).signin(
            _authData['email'].toString(), _authData['password'].toString());
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
            _authData['email'].toString(), _authData['password'].toString());
      }
    } on HttpException catch (error) {
      print(error);
      //filtering the error with HttpException
      var errorMessage = 'Authentication Failed.';
      if (error.message.contains('EMAIL_EXISTS')) {
        errorMessage = 'This email is already in use.';
      } else if (error.message.contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address.';
      } else if (error.message.contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.message.contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.message.contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showDialog(errorMessage);
    } catch (error) {
      print(error);

      var errorMessage = 'Could not authenticate you. Please try again later.';
      _showDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        width: deviceSize.width * 0.75,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        padding: EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty || !value.contains('@')) {
                        return 'invalid';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value.toString();
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return 'Password is too short';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value.toString();
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Password do not match';
                              }
                            }
                          : null,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    ElevatedButton(
                      style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 8.0))),
                      onPressed: _submit,
                      child: Text(
                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    ),
                  TextButton(
                    onPressed: _switchMode,
                    style: ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                      ),
                    ),
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
